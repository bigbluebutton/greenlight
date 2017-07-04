# Stores data on waiting users on the server side so
# we can pass it to clients when they reload the page.

class WaitingList
  @waiting = {}
  
  def self.waiting
    @waiting
  end
  
  def self.add(room, user, meeting)
    @waiting[room] = {} unless @waiting.has_key?(room)
    @waiting[room][meeting] = [] unless @waiting[room].has_key?(meeting)
    @waiting[room][meeting] << user
  end
  
  def self.remove(room, user, meeting)
    if @waiting.has_key?(room) then
      if @waiting[room].has_key?(meeting) then
        @waiting[room][meeting].slice!(@waiting[room][meeting].index(user))
        @waiting[room].delete(meeting) if @waiting[room][meeting].length == 0
        @waiting.delete(room) if @waiting[room].length == 0
      end
    end
  end
  
  def self.empty(room, meeting)
    if @waiting.has_key?(room) then
      if @waiting[room].has_key?(meeting) then
        @waiting[room].delete(meeting)
        @waiting.delete(room) if @waiting[room].length == 0
      end
    end
  end
end
