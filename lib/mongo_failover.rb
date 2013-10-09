require 'mongo'
require 'active_support/core_ext/module/aliasing'

#Auto failover on connection error
module Mongo

  DEFAULT_WRITE_SAFETY = {:w => 1}

  def self.default_write_safety(opts={})
    DEFAULT_WRITE_SAFETY.merge(opts)
  end
  
  class Collection
    def find_with_retry(selector={}, opts={}, &block)
      rescue_connection_failure do
        find_without_retry(selector, opts, &block)
      end
    end

    def update_with_retry(selector, document, opts={})
      rescue_connection_failure do
        update_without_retry(selector, document, opts)
      end
    end

    def insert_with_retry(doc, opts={})
      rescue_connection_failure do
        insert_without_retry(doc, opts={})
      end
    end
    
    def remove_with_retry(selector={}, opts={})
      rescue_connection_failure do
        remove_without_retry(selector, opts)
      end
    end

    def create_index_with_retry(spec, opts={})
      rescue_connection_failure do
        create_index_without_retry(spec, opts)
      end
    end

    def drop_index_with_retry(name)
      rescue_connection_failure do
        drop_index_without_retry(name)
      end
    end

    def drop_indexes_with_retry
      rescue_connection_failure do
        drop_indexes_without_retry
      end
    end

    def drop_with_retry
      rescue_connection_failure do
        drop_without_retry
      end
    end

    def find_and_modify_with_retry(opts={})
      rescue_connection_failure do
        find_and_modify_without_retry(opts)
      end
    end
    
    def map_reduce_with_retry(map, reduce, opts={})
      rescue_connection_failure do
        map_reduce_without_retry(map, reduce, opts)
      end
    end

    def group_with_retry(key, condition={}, initial={}, reduce=nil, finalize=nil)
      rescue_connection_failure do
        group_without_retry(key, condition, initial, reduce, finalize)
      end
    end

    def new_group_with_retry(opts={})
      rescue_connection_failure do
        new_group_without_retry(opts)
      end
    end

    def distinct_with_retry(key, query=nil)
      rescue_connection_failure do
        distinct_without_retry(key, query)
      end
    end

    def rename_with_retry(new_name)
      rescue_connection_failure do
        new_name_without_retry(new_name)
      end
    end

    def index_information_with_retry
      rescue_connection_failure do
        index_information_without_retry
      end
    end

    def options_with_retry
      rescue_connection_failure do
        options_without_retry
      end
    end

    def stats_with_retry
      rescue_connection_failure do
        stats_without_retry
      end
    end

    def count_with_retry
      rescue_connection_failure do
        count_without_retry
      end
    end

    alias_method_chain :find, :retry
    alias_method_chain :update, :retry
    alias_method_chain :insert, :retry
    alias_method_chain :remove, :retry
    alias_method_chain :create_index, :retry
    alias_method_chain :drop_index, :retry
    alias_method_chain :drop_indexes, :retry
    alias_method_chain :drop, :retry
    alias_method_chain :find_and_modify, :retry
    alias_method_chain :map_reduce, :retry
    alias_method_chain :group, :retry
    alias_method_chain :new_group, :retry
    alias_method_chain :distinct, :retry
    alias_method_chain :rename, :retry
    alias_method_chain :index_information, :retry
    alias_method_chain :options, :retry
    alias_method_chain :stats, :retry
    alias_method_chain :count, :retry

    def ensure_index_with_warning(spec, opts={})
      # ensure_index is fine for global databases
      if Site.site_id == db.name
        Rails.logger.warn "ensure_index no longer relevant to multi-tenant architecture!  Add new indexes into #{MongoIndexer.yml_file_dir}.  Collection #{self.name} Spec: #{spec}"
      else
        rescue_connection_failure do
          ensure_index_without_warning(spec, opts={})
        end
      end
    end
    alias_method_chain :ensure_index, :warning

    private
    def rescue_connection_failure(attempts=0, &block)
      yield
    rescue Mongo::ConnectionFailure
      if attempts < 10
        sleep(0.1)
        rescue_connection_failure(attempts + 1, &block)
      else
        raise $!
      end
    rescue Mongo::OperationFailure
      if db.connection['admin'].command({:ismaster => 1})['ismaster']
        raise $!
      else
        db.connection.connect
        yield
      end
    end
  end

  class DB

    def profiling_level_with_retry=(level)
      rescue_connection_failure do
        profiling_level_without_retry=(level)
      end
    end

    def profiling_level_with_retry
      rescue_connection_failure do
        profiling_level_without_retry
      end
    end

    def profiling_info_with_retry
      rescue_connection_failure do
        profiling_info_without_retry
      end
    end

    def get_last_error_with_retry(opts={})
      rescue_connection_failure do
        get_last_error_without_retry(opts)
      end
    end

    def previous_error_with_retry
      rescue_connection_failure do
        previous_error_without_retry
      end
    end

    alias_method_chain :profiling_level=, :retry
    alias_method_chain :profiling_level, :retry
    alias_method_chain :profiling_info, :retry
    alias_method_chain :get_last_error, :retry
    alias_method_chain :previous_error, :retry

    private
    def rescue_connection_failure(attempts=0, &block)
      yield
    rescue Mongo::ConnectionFailure
      puts "8========= rescued ==========D"
      puts "attempts: #{attempts.inspect}"
      
      if attempts < 10
        sleep(0.1)
        rescue_connection_failure(attempts + 1, &block)
      else
        raise $!
      end
    rescue Mongo::OperationFailure
      if connection['admin'].command({:ismaster => 1})['ismaster']
        raise $!
      else
        connection.connect
        yield
      end
    end
  end
end