module MiniSpec
  module InstanceAPI

    # basically by proxying an object we attach a spy on it
    # so any received messages will be reported
    #
    # @example  spying user for :login and :logout messages
    #   user = User.new
    #   spy(user, :login, :logout)
    #   # ...
    #   assert(user).received(:login, :logout)
    #
    def spy object, *methods
      methods.each {|method| proxy(object, method)}
    end
  end
end
