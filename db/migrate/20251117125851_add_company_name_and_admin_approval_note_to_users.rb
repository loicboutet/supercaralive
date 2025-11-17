class AddCompanyNameAndAdminApprovalNoteToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :company_name, :string
    add_column :users, :admin_approval_note, :text
  end
end
