#!/usr/bin/env ruby
# Test script for Solid Queue
# This script will test if Solid Queue is properly configured

require_relative 'config/environment'

puts "=" * 60
puts "Testing Solid Queue Configuration"
puts "=" * 60

# Test 1: Check if Solid Queue adapter is configured
puts "\n1. Checking Active Job adapter..."
adapter = Rails.application.config.active_job.queue_adapter
puts "   Active Job adapter: #{adapter}"
if adapter == :solid_queue
  puts "   ✓ Solid Queue adapter is configured correctly"
else
  puts "   ✗ Solid Queue adapter is NOT configured (found: #{adapter})"
  exit 1
end

# Test 2: Check if Solid Queue tables exist in the database
puts "\n2. Checking for Solid Queue tables in database..."
begin
  if ActiveRecord::Base.connection.table_exists?('solid_queue_jobs')
    puts "   ✓ solid_queue_jobs table exists"
  else
    puts "   ✗ solid_queue_jobs table does NOT exist"
    puts "   You may need to run: bin/rails db:migrate"
    exit 1
  end
rescue => e
  puts "   ✗ Error checking database: #{e.message}"
  exit 1
end

# Test 3: Enqueue a test job
puts "\n3. Testing job enqueueing..."
begin
  job = TestJob.perform_later("Solid Queue test from script!")
  puts "   ✓ Job enqueued successfully"
  puts "   Job ID: #{job.job_id}"
rescue => e
  puts "   ✗ Error enqueueing job: #{e.message}"
  puts "   #{e.backtrace.first}"
  exit 1
end

# Test 4: Check if job is in the database
puts "\n4. Verifying job in database..."
begin
  job_record = SolidQueue::Job.find_by(active_job_id: job.job_id)
  if job_record
    puts "   ✓ Job found in database"
    puts "   Queue: #{job_record.queue_name}"
    puts "   Class: #{job_record.class_name}"
    puts "   Status: #{job_record.finished_at ? 'Finished' : 'Pending'}"
  else
    puts "   ⚠ Job not found in database (may be processed already)"
  end
rescue => e
  puts "   ⚠ Could not check job in database: #{e.message}"
end

# Test 5: Check queue configuration
puts "\n5. Checking queue configuration..."
begin
  config_path = Rails.root.join('config', 'queue.yml')
  if File.exist?(config_path)
    puts "   ✓ queue.yml configuration file exists"
  else
    puts "   ✗ queue.yml configuration file not found"
  end
rescue => e
  puts "   ⚠ Error checking config: #{e.message}"
end

puts "\n" + "=" * 60
puts "Test Summary"
puts "=" * 60
puts "Solid Queue appears to be properly configured!"
puts "Note: To process jobs, make sure 'bin/jobs' is running"
puts "      (it should start automatically with 'bin/dev')"
puts "=" * 60

