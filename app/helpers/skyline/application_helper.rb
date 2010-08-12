module Skyline::ApplicationHelper  
  # Place a tick or a cross depending on the value of bool
  #
  # @param [Boolean] bool The value of the tick/cross
  # @param [Hash] options ({}) Options will be passed to the image_tag method
  def tick_image(bool,options={})
    name = bool ? "true" : "false"
    src = "/skyline/images/icons/#{name}.gif"
    
    options.reverse_merge! :alt => t(name, :scope => [:icons]) 
    
    image_tag(src,options)
  end
  
  # You can use this method to place a message directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # @param [Symbol] type The type of the message (:error,:notification,:success)
  # @param [String] message The message to show
  # @param [Hash] options ({}) Options to be passed to the MessageGenerator (javascript)
  def message(type,message,options={})
    Skyline::MessageGenerator.new(type,message,options)
  end

  # You can use this method to place a notification directly in your view. This also
  # works directly from a render(:update) or an update_page block. 
  # 
  # @param [Symbol] type The type of the message (:error,:notification,:success)
  # @param [String] message The message to show
  # @param [Hash] options ({}) Options to be passed to the MessageGenerator (javascript)
  def notification(type,message,options={})
    Skyline::NotificationGenerator.new(type,message,options)    
  end
  
  # Actually render the messages on screen.
  # 
  # @option options [Class] :generator (Skyline::MessageGenerator) The generator to use to render the messages.
  def render_messages(options={})
    _render_volatiles(self.messages,options)
  end
  
  # Actually render the notifications on screen.
  #
  # @option options [Class] :generator (Skyline::NotificationGenerator) The generator to use to render the messages.
  def render_notifications(options={})
    options.reverse_merge! :generator => Skyline::NotificationGenerator
    _render_volatiles(self.notifications,options)
  end
    
  protected
  
  def _render_volatiles(messages_hash, options={})
    return "" unless messages_hash.any?
    options.reverse_merge! :generator => Skyline::MessageGenerator
    generator = options.delete(:generator)
    out = messages_hash.inject([]) do |acc,v|
      type,messages = v[0],[v[1]].flatten
      msg_options = messages.extract_options!
      msg_options.reverse_merge! options
      acc += messages.map{|msg| generator.new(type,msg,msg_options) }
    end
    javascript_tag out.join("\n")    
  end
end