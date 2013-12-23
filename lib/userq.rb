module UserQ

  class Queue
    attr_accessor :queue_constraints

    # pre: constraints is a hash - capacity (int), taken (int), entry_time (int of seconds)
    # post: instance of UserQ::Queue
    def initialize constraints = {}
      self.queue_constraints = { context: 'all', capacity: 2, taken: 0, entry_time: 180, auto_clean: true }.merge(constraints)
    end

    def constraints input # Update the constraints
      queue_constraints.merge!(input)
    end

    def constraint input # Alias of self.constraints
      constraints(input)
    end


    # Beautiful syntax.

    def enter_into_queue? # Check if enough space in queue
      current_limit = queue_constraints[:capacity].to_i
      current_usage = queue_constraints[:taken].to_i + UserQ::UserQueue.count_unexpired(queue_constraints[:context])

      # Assess whether enough space left into queue
      current_usage < current_limit
    end

    def nearest_entry # In seconds how long the next entry in the queue will expire.
      UserQ::UserQueue.next_in_seconds(queue_constraints[:context])
    end

    def avg_wait_time # nearest_time but more human-readable
      case nearest_entry.floor
      when 0..30
        return "Less than 30 seconds"
      when 31..60
        return "Less than a minute"
      else
        return "approximately #{(nearest_entry.floor / 60).floor} minutes"
      end
    end

    def empty?
      UserQ::UserQueue.count_in_context(queue_constraints[:context]) == 0
    end

    def empty_queue # Clean entries that aren't ever going to be re-used.
      UserQ::UserQueue.empty(queue_constraints[:context])
      true
    end

    def reset
      UserQ::UserQueue.reset(queue_constraints[:context])
      true
    end

    def enter data = {}
      return false unless enter_into_queue?

      entry = UserQ::UserQueue.new
      entry.code = UserQ::Internal.generate_code
      entry.expires_at = UserQ::Internal.current_time + queue_constraints[:entry_time]
      entry.data = data.to_json
      entry.context = queue_constraints[:context]
      entry.save

      # Automatically clean expired tokens. Woohoo!
      empty_queue if queue_constraints[:auto_clean]

      Entry.new(entry.code)
    end

  end

  class Entry
    attr_accessor :code, :entry

    def initialize code
      self.entry = UserQ::UserQueue.find_by_code(self.code = code)
      raise "Entry code #{code} not valid" if self.entry.count == 0

      # Woohoo!
      self.entry = self.entry.first
    end

    def valid_context? context
      entry.context == context
    end

    def expired?
      entry.expires_at < UserQ::Internal.current_time
    end

    def alive? # Opposite of expired?
      entry.expires_at >= UserQ::Internal.current_time
    end

    def expires
      expires = (entry.expires_at - UserQ::Internal.current_time).floor
      expires > -1 ? expires : -1
    end

    def expire
      entry.expires_at = UserQ::Internal.current_time - 1
      entry.save
      true
    end

    def remove
      entry.destroy
      entry = nil
      code = nil
      true
    end

    def removed?
      true if entry.nil? or code.nil?
      false
    end

    def shorten seconds

      entry.expires_at -= seconds if entry.expires_at >= UserQ::Internal.current_time
      entry.save

      expires
    end

    def extend seconds

      if entry.expires_at < UserQ::Internal.current_time
        entry.expires_at = UserQ::Internal.current_time + seconds
      else
        entry.expires_at += seconds
      end

      entry.save
      expires
    end

    def alive
      entry.created_at - UserQ::Internal.current_time
    end

    def data
      entry.data || Hash.new
    end
  end

  # UserQ::Queue.constraint(capacity: 100)


  class UserQueue < ActiveRecord::Base
    def self.find_by_code code
      where(code: code)
    end

    def self.count_unexpired context
      where(context: context).where("expires_at > ?", UserQ::Internal.current_time).count
    end

    def self.count_in_context context
      where(context: context).count
    end

    def self.reset context
      where(context: context).destroy_all
    end

    def self.next_in_seconds context
      seconds = (where(context: context).order(expires_at: :asc).first.expires_at - UserQ::Internal.current_time).to_i
      seconds > 0 ? seconds : 0
    end

    def self.empty context
      where(context: context).where("expires_at <= ?", UserQ::Internal.current_time).destroy_all
    end
  end


  # Useful internal tools we use to make it beautiful.
  class Internal
    def self.symbolize array
      result = {}
      array.each { |key, value| result[key.to_sym] = value }
      result
    end

    def self.current_time # Time all comes from here. Beautiful to update.
      Time.now
    end

    def self.generate_code
      rand(36**24).to_s(36)
    end
  end

end