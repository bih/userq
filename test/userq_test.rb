require 'test_helper'

class UserqTest < ActiveSupport::TestCase


  test "if modules are available" do
    assert_kind_of Module, UserQ, "Module UserQ does not exist"
    assert_kind_of Class, UserQ::Queue, "Class UserQ::Queue does not exist"
    assert_kind_of Class, UserQ::Entry, "Class UserQ::Entry does not exist"
    assert_kind_of Class, UserQ::UserQueue, "Class UserQ::UserQueue does not exist"
    assert_kind_of Class, UserQ::Internal, "Class UserQ::Internal does not exist"
  end

  test "migration should exist" do
    migration_exists = Dir["test/dummy/db/migrate/*_create_user_queues.rb"].count > 0
    assert migration_exists, "migration file for UserQ does not exist"
  end

  test "should be able to create instance of a queue" do
    assert_instance_of UserQ::Queue, UserQ::Queue.new(context: 'test', capacity: 5, taken: 2, entry_time: 5, auto_clean: true), "Instance of UserQ::Queue could not be created"
  end

  test "should be able to access existing entry under same context" do
    instance = UserQ::Queue.new(context: 'test', capacity: 5, taken: 2, entry_time: 5, auto_clean: true)
    instance.reset
    code_for_created_entry = instance.enter.code

    assert UserQ::Entry.new(code_for_created_entry).entry.context == "test", "New entry in Queue could not be recognized as UserQ::Entry"
  end

  test "should NOT be able to access existing entry under different context" do
    instance = UserQ::Queue.new(context: 'test', capacity: 5, taken: 2, entry_time: 5, auto_clean: true)
    instance.reset
    code_for_created_entry = instance.enter.code

    assert_not UserQ::Entry.new(code_for_created_entry).entry.context == "not_a_test", "New entry in Queue is recognized a different context (should not happen)"
  end

  test "should not allow more than 5 requests" do
    instance = UserQ::Queue.new(context: 'test', capacity: 5, taken: 0, entry_time: 5, auto_clean: true)
    instance.reset

    5.times do
      instance.enter
    end

    assert_not instance.enter, "More than 5 Queue entries are being allowed (when 5 was a defined limit)"
  end

  test "should not allow more than 5 requests with 2 already taken" do
    instance = UserQ::Queue.new(context: 'test', capacity: 5, taken: 2, entry_time: 5, auto_clean: true)
    instance.reset

    3.times do
      instance.enter
    end

    assert_not instance.enter, "More than 3 Queue entries are being allowed (when 5 was a defined limit with 2 already taken)"
  end

  test "average wait time should be rightly calculated" do
    instance = UserQ::Queue.new(context: 'test', capacity: 5, entry_time: 10, auto_clean: true)
    instance.reset

    5.times { instance.enter }
    assert_not instance.enter_into_queue?, "was not able to enter queue"

    # average wait time should be 10 seconds
    # well, 9 seconds.
    assert_equal "Less than 30 seconds", instance.avg_wait_time
    assert_equal 9, instance.nearest_entry

    # now for longer time
    instance = UserQ::Queue.new(context: 'test', capacity: 5, entry_time: 150, auto_clean: true)
    instance.reset

    5.times { instance.enter }

    # average wait time should be 150 seconds (aka 2 minutes rounded down)
    # well, 149 seconds.
    assert_equal "approximately 2 minutes", instance.avg_wait_time
    assert_equal 149, instance.nearest_entry
  end

  test "queue should be closed and then re-opened after time expires" do
    instance = UserQ::Queue.new(context: 'test', capacity: 1, entry_time: 5, auto_clean: true)
    instance.reset
    assert instance.enter_into_queue?, "Was not able to enter into queue"
    
    entry = instance.enter
    assert_not instance.enter_into_queue?, "Was able to enter in queue before 1 capacity had expired"

    entry.expire # Should be expired.
    assert entry.expired?, "Entry not considered expired"

    entry.shorten(5) # Should again be expired.
    assert entry.expired?, "Entry not considered expired"

    assert instance.enter_into_queue?, "Was not able to re-enter into queue"
  end
  
end
