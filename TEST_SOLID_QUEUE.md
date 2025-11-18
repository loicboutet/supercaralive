# Testing Solid Queue Setup

This document describes how to test that Solid Queue is properly configured.

## Prerequisites

1. Make sure you have Ruby 3.3.3 installed (or the version specified in `.ruby-version`)
2. Run `bundle install` to ensure all gems are installed
3. Run database migrations: `bin/rails db:migrate`

## Test Steps

### 1. Verify Configuration Files

Check that the following files are properly configured:

- ✅ `config/environments/development.rb` - Should have `config.active_job.queue_adapter = :solid_queue`
- ✅ `Procfile.dev` - Should have `jobs: bin/jobs` line
- ✅ `config/queue.yml` - Should exist with proper configuration
- ✅ `bin/jobs` - Should exist and be executable

### 2. Run Database Migrations

Make sure Solid Queue tables are created in your development database:

```bash
bin/rails db:migrate
```

This will create all the necessary Solid Queue tables in your development database.

### 3. Start the Development Environment

Start all services including the job processor:

```bash
bin/dev
```

This should start:
- Rails server (web)
- Tailwind CSS watcher (css)
- Solid Queue job processor (jobs)

### 4. Test Job Enqueueing

Open a Rails console in a new terminal:

```bash
bin/rails console
```

Then enqueue a test job:

```ruby
TestJob.perform_later("Hello from Solid Queue!")
```

You should see output indicating the job was enqueued.

### 5. Verify Job Processing

Check the logs from `bin/dev` to see if the job was processed. You should see something like:

```
[ActiveJob] [TestJob] [<job_id>] Performing TestJob with arguments: ["Hello from Solid Queue!"]
[ActiveJob] [TestJob] [<job_id>] TestJob executed: Hello from Solid Queue!
[ActiveJob] [TestJob] [<job_id>] Performed TestJob in <time>ms
```

### 6. Check Job in Database (Optional)

In the Rails console, you can check if the job was processed:

```ruby
# Check if job exists
job = SolidQueue::Job.last
puts "Job: #{job.class_name}, Status: #{job.finished_at ? 'Finished' : 'Pending'}"
```

## Automated Test Script

You can also run the automated test script (requires Ruby to be properly configured):

```bash
ruby test_solid_queue.rb
```

This script will:
1. Verify the Active Job adapter is set to `:solid_queue`
2. Check if Solid Queue tables exist in the database
3. Enqueue a test job
4. Verify the job was created in the database
5. Check configuration files

## Troubleshooting

### Issue: "solid_queue_jobs table does NOT exist"

**Solution**: Run `bin/rails db:migrate` to create the tables.

### Issue: Jobs are not being processed

**Solution**: 
- Make sure `bin/dev` is running and the `jobs` process is started
- Check the logs for any errors
- Verify `config/queue.yml` is properly configured

### Issue: "rbenv: version `ruby-3.3.3' is not installed"

**Solution**: Install the correct Ruby version or update `.ruby-version` to match your installed version.

## Cleanup

After testing, you can remove the test job file:

```bash
rm app/jobs/test_job.rb
rm test_solid_queue.rb
rm TEST_SOLID_QUEUE.md
```


