$:.unshift '.';require File.dirname(__FILE__) + '/helper'

class FailoverTest < Test::Unit::TestCase

  context 'a connection and a db' do 
    setup do 
      @connection = Mongo::Connection.new('localhost', 27017)
      @db = @connection.db('mongo_failover_test')
    end

    should 'alias them methods' do 
      Mongo::Collection.any_instance.expects(:rescue_connection_failure).once
      perform_find
    end

    context 'with a single Mongo::ConnectionFailure' do 
      setup do 
        Mongo::Collection.any_instance.stubs(:find_without_retry).raises(Mongo::ConnectionFailure).then.returns(nil)
      end

      should 'retry and not bubble up the error' do 
        perform_find
      end
    end

    context 'with persistent Mongo::ConnectionFailure' do 
      setup do 
        Mongo::Collection.any_instance.stubs(:find_without_retry).raises(Mongo::ConnectionFailure)
      end

      should 'bubble up the error' do
        assert_raises(Mongo::ConnectionFailure) do 
          perform_find
        end
      end
    end
  end


  def perform_find
    @db.collection('test').find({})
  end

end