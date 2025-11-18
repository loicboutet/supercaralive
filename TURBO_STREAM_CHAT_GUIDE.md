# Guide: Chat en temps réel avec Turbo Streams - Hatmada

Ce guide explique comment implémenter un système de chat en temps réel avec Turbo Streams dans votre application Rails, basé sur l'implémentation existante de Hatmada.

## Vue d'ensemble du système

Le chat utilise **Turbo Streams** pour mettre à jour l'interface en temps réel sans rechargement de page. Voici les composants clés :

- **Models** : `Chat` et `Message` avec callbacks Turbo Stream
- **Controller** : `MessagesController` avec réponses Turbo Stream
- **Views** : Partials avec `turbo_stream_from` et `turbo_frame_tag`
- **Broadcasting** : Diffusion automatique des nouveaux messages

## 1. Structure des Models

### Model Chat

```ruby
class Chat < ApplicationRecord
  belongs_to :commercial, class_name: "User"
  belongs_to :manager, class_name: "User"
  has_many :messages, dependent: :destroy

  validates :name, presence: true

  # Auto-set name with user names
  before_validation :set_name, on: :create

  # Scope pour ordonner par dernier message
  scope :ordered_by_last_message, -> {
    left_joins(:messages)
      .group("chats.id")
      .order("MAX(messages.created_at) DESC NULLS LAST")
  }

  def last_message
    messages.order(:created_at).last
  end

  def other_user(current_user)
    current_user == commercial ? manager : commercial
  end

  def has_unread_messages_for?(user)
    messages
      .where(read: false)
      .where(Message.arel_table[:user_id].not_eq(user.id).or(Message.arel_table[:user_id].eq(nil)))
      .exists?
  end

  def mark_messages_as_read_for!(user)
    messages.where.not(user: user).where(read: false).update_all(read: true)
    messages.where(user: nil).where(read: false).update_all(read: true)
  end

  private

  def set_name
    if commercial && manager
      self.name = "#{commercial.get_full_name} - #{manager.get_full_name}"
    end
  end
end
```

### Model Message (CLÉS TURBO STREAM)

```ruby
class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user, optional: true

  validates :content, presence: true, length: { maximum: 1000 }

  # 🔑 CALLBACKS TURBO STREAM ESSENTIELS
  after_create_commit :broadcast_message

  scope :recent, -> { order(:created_at) }

  def system?
    user.nil?
  end

  private

  # 🔑 MÉTHODE DE BROADCAST PRINCIPALE
  def broadcast_message
    # Ajouter le nouveau message à la liste
    broadcast_append_to(
      "chat_#{chat.id}",           # Canal de diffusion
      target: "messages",          # ID de l'élément cible
      partial: "messages/message", # Partial à rendre
      locals: { message: self, current_user: user }
    )

    # Action personnalisée pour faire défiler vers le bas
    broadcast_action_to(
      "chat_#{chat.id}",
      action: :scroll_to_bottom,
      target: "messages_container"
    )
  end
end
```

## 2. Controller Pattern

### MessagesController

```ruby
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [:show, :create]

  def messaging
    @chats = current_user.chats.includes(:messages, :commercial, :manager)
                        .ordered_by_last_message

    @selected_chat = @chats.find_by(id: params[:chat_id]) || @chats.first

    if @selected_chat
      @selected_chat.mark_messages_as_read_for!(current_user)
      @messages = @selected_chat.messages.includes(:user).recent.last(50)
      @message = Message.new
    end
  end

  def show
    @chat.mark_messages_as_read_for!(current_user)
    @messages = @chat.messages.includes(:user).recent.last(50)
    @message = Message.new

    respond_to do |format|
      # 🔑 RÉPONSE TURBO STREAM POUR CHANGER DE CHAT
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "chat_content",
          partial: "messages/chat_content",
          locals: { chat: @chat, messages: @messages, message: @message, current_user: current_user }
        )
      end
      format.html { redirect_to messaging_path(chat_id: @chat.id) }
    end
  end

  def create
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    respond_to do |format|
      if @message.save
        # 🔑 RÉPONSE TURBO STREAM VIDE - Le broadcast se fait automatiquement
        format.turbo_stream
        format.html { redirect_to messaging_path(chat_id: @chat.id) }
      else
        # Gestion des erreurs avec Turbo Stream
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "message_form",
            partial: "messages/message_form",
            locals: { chat: @chat, message: @message }
          )
        end
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id] || params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content, :document, :document_title)
  end
end
```

## 3. Structure des Views

### Vue principale (messaging.html.erb)

```erb
<div class="bg-white rounded-lg shadow md:h-[600px]">
  <div class="grid grid-cols-1 md:grid-cols-3 h-full">
    
    <!-- Liste des conversations -->
    <div class="border-r border-gray-200">
      <!-- Liste des chats -->
      <% @chats.each do |chat| %>
        <%= render "messages/chat_item", chat: chat, selected: (@selected_chat == chat) %>
      <% end %>
    </div>

    <!-- Fenêtre de chat -->
    <div class="col-span-2 flex flex-col h-[600px] md:h-full" id="chat_content_wrapper">
      <% if @selected_chat %>
        <%= render "messages/chat_content", chat: @selected_chat, messages: @messages, message: @message %>
      <% end %>
    </div>
  </div>
</div>

<!-- 🔑 ABONNEMENT TURBO STREAM GLOBAL -->
<%= turbo_stream_from "messaging_#{current_user.id}" %>
```

### Contenu du chat (_chat_content.html.erb)

```erb
<!-- 🔑 TURBO FRAME POUR REMPLACEMENTS -->
<%= turbo_frame_tag "chat_content", class: "h-[600px] flex flex-col" do %>
  
  <!-- En-tête du chat -->
  <div class="p-4 border-b border-gray-200">
    <h3><%= chat.other_user(current_user).get_full_name %></h3>
  </div>

  <!-- 🔑 CONTENEUR DES MESSAGES -->
  <div 
    class="flex-1 overflow-y-auto"
    id="messages_container" 
    data-controller="chat" 
    data-chat-id-value="<%= chat.id %>"
  >
    <!-- 🔑 CIBLE POUR LES NOUVEAUX MESSAGES -->
    <div id="messages">
      <%= render "messages/messages_batch", messages: messages, current_user: current_user %>
    </div>
  </div>

  <!-- Formulaire de message -->
  <div class="p-4 border-t border-gray-200">
    <%= render "messages/message_form", chat: chat, message: message %>
  </div>

  <!-- 🔑 ABONNEMENT TURBO STREAM SPÉCIFIQUE AU CHAT -->
  <%= turbo_stream_from "chat_#{chat.id}" %>
<% end %>
```

### Formulaire de message (_message_form.html.erb)

```erb
<!-- 🔑 FORMULAIRE AVEC TURBO ACTIVÉ -->
<%= form_with model: [chat, message], 
    url: chat_messages_path(chat), 
    data: { turbo: true },
    id: "message_form" do |form| %>
  
  <div class="flex space-x-3">
    <%= form.text_field :content, 
        placeholder: "Tapez votre message...", 
        class: "flex-1 px-4 py-2 border rounded-full",
        autocomplete: "off" %>
    
    <%= form.submit "Envoyer", 
        class: "bg-blue-500 text-white px-4 py-2 rounded-full",
        data: { disable_with: "..." } %>
  </div>
<% end %>
```

### Partial de message (_message.html.erb)

```erb
<div class="flex mx-6 my-2" id="message_<%= message.id %>">
  <div class="max-w-xs lg:max-w-md">
    <div class="message-bubble rounded-lg p-3">
      <p class="text-sm">
        <%= simple_format(h(message.content)) %>
      </p>
    </div>
    <p class="text-xs text-gray-500 mt-1">
      <%= message.formatted_time %>
    </p>
  </div>
</div>
```

### Vue Turbo Stream pour création (_create.turbo_stream.erb_)

```erb
<!-- 🔑 AJOUTER LE NOUVEAU MESSAGE -->
<%= turbo_stream.append "messages" do %>
  <%= render "messages/message", message: @message, current_user: current_user %>
<% end %>

<!-- 🔑 RÉINITIALISER LE FORMULAIRE -->
<%= turbo_stream.replace "message_form" do %>
  <%= render "messages/message_form", chat: @chat, message: Message.new %>
<% end %>

<!-- 🔑 ACTION PERSONNALISÉE POUR DÉFILER -->
<%= turbo_stream.action :scroll_to_bottom, "messages_container" %>
```

## 4. Routes nécessaires

```ruby
# Dans config/routes.rb
get "messaging", to: "messages#messaging", as: :messaging
get "messages/:id", to: "messages#show", as: :message_chat
post "messages/:id/messages", to: "messages#create", as: :chat_messages
```

## 5. Points clés pour le fonctionnement

### A. Callbacks essentiels dans le Model

```ruby
# Dans Message model
after_create_commit :broadcast_message

def broadcast_message
  # Diffuser à tous les utilisateurs du chat
  broadcast_append_to(
    "chat_#{chat.id}",
    target: "messages",
    partial: "messages/message",
    locals: { message: self, current_user: user }
  )
end
```

### B. Abonnements Turbo Stream dans les vues

```erb
<!-- Abonnement global -->
<%= turbo_stream_from "messaging_#{current_user.id}" %>

<!-- Abonnement spécifique au chat -->
<%= turbo_stream_from "chat_#{chat.id}" %>
```

### C. IDs et targets importants

- `id="messages"` : Cible pour `broadcast_append_to`
- `id="message_form"` : Cible pour réinitialiser le formulaire
- `id="messages_container"` : Cible pour actions personnalisées
- `id="chat_content"` : Cible pour changer de chat

### D. Réponses controller

```ruby
def create
  if @message.save
    # Réponse vide - le broadcast automatique gère tout
    format.turbo_stream
  else
    # Gestion d'erreur avec remplacement du formulaire
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace("message_form", ...)
    end
  end
end
```

## 6. Fonctionnalités avancées

### A. Actions personnalisées

```ruby
# Dans le model Message
broadcast_action_to(
  "chat_#{chat.id}",
  action: :scroll_to_bottom,
  target: "messages_container"
)
```

### B. Gestion des erreurs

```erb
<!-- Dans create.turbo_stream.erb -->
<% if @message.errors.any? %>
  <%= turbo_stream.replace "message_form" do %>
    <%= render "messages/message_form", chat: @chat, message: @message %>
  <% end %>
<% end %>
```

### C. Indicateur de frappe (optionnel)

```javascript
// Stimulus controller pour indicateur de frappe
export default class extends Controller {
  startTyping() {
    // Logique d'indicateur de frappe
  }
}
```

## 7. Checklist d'implémentation

- [ ] **Models** : Ajouter `after_create_commit :broadcast_message`
- [ ] **Controller** : Réponses `format.turbo_stream`
- [ ] **Routes** : Routes pour messaging et création de messages
- [ ] **Vue principale** : `turbo_stream_from` global
- [ ] **Vue chat** : `turbo_frame_tag` et `turbo_stream_from` spécifique
- [ ] **Formulaire** : `data: { turbo: true }`
- [ ] **Partials** : IDs corrects pour les targets
- [ ] **Vue Turbo Stream** : `create.turbo_stream.erb`

## 8. Dépannage courant

### Messages ne s'affichent pas en temps réel
- Vérifier `after_create_commit :broadcast_message`
- Vérifier `turbo_stream_from "chat_#{chat.id}"`
- Vérifier l'ID `messages` dans la vue

### Formulaire ne se réinitialise pas
- Vérifier `turbo_stream.replace "message_form"`
- Vérifier l'ID `message_form`

### Erreurs de broadcast
- Vérifier que les partials existent
- Vérifier les paramètres `locals`

Ce guide couvre tous les aspects essentiels pour implémenter un chat temps réel avec Turbo Streams dans votre application Rails.
