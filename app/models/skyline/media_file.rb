# @private
class Skyline::MediaFile < Skyline::MediaNode      
  include Skyline::Taggable

  after_create :store_data
  after_destroy :remove_data, :reset_ref_object
  validates_presence_of :data, :on => :create
  validates_uniqueness_of :name, :scope => "parent_id"
  
  has_many :media_sizes, :foreign_key => "media_file_id", :class_name => 'Skyline::MediaSize', :dependent => :destroy
  
  default_scope :order => :name
  
  attr_accessible :name, :data
  
  # returns thumbnail of image
  # ==== Parameters
  # width<Integer>:: required width of the thumbnail
  # height<Integer>:: required height of the thumbnail
  #
  # ==== Returns
  # <ImageBlob>:: blob of the Magick::Image  
  def thumbnail(width=100,height=100)
    img = Magick::Image::read(self.file_path).first
    
    width,height = self.proportional_dimension(width,height,img.columns,img.rows)
    
    stream = img.change_geometry!("#{width}x#{height}"){ |c,r,i| i.resize!(c,r) }
    stream.to_blob        
  end

  # returns the dimension of the original image
  #
  # ==== Returns
  # <Hash>:: hash of width and height attributes
  def dimension
    return nil unless self.resizable?
    {"width" => self.width, "height" => self.height}
  end
  
  # returns true if the file is resizable (ie, an image), false otherwise
  #
  # ==== Returns
  # <Boolean>:: true if file is resizable, false otherwise
  def resizable?
    self.file_type == 'image'
  end
  
  # Calculate the proportional dimension of this media file
  # this method will never go beyond the bounds of org_w and org_h.
  # 
  # @param width [Integer] The target width of this calculation
  # @param height [Integer] The target height of this calculation
  # @param org_w [Integer] The original width
  # @param org_h [Integer] The origin height
  #
  # @return Array<Integer,Integer> The new width and height
  def proportional_dimension(width,height,org_w = self.width, org_h = self.height)
    return nil if org_w.blank? && org_h.blank?
    
    # Make sure we don't go beyond the actual size!
    if (width.to_i > org_w || height.to_i > org_h) 
      width = [width.to_i, org_w].min
      height = [height.to_i, org_h].min
    end
    
    w_factor = width.to_f / org_w.to_f
    h_factor = height.to_f / org_h.to_f
    factor = case 
      when w_factor == 0 then h_factor
      when h_factor == 0 then w_factor
      else [w_factor, h_factor].min
    end
    
    [(org_w*factor).round, (org_h*factor).round]
  end
  
  # sanitize filename and set correct mime-type for IO object of file data
  #
  # ==== Parameters
  # data<IO>:: IO object with file data
  #
  # ==== Returns
  # data<IO>:: IO object with sanitized filename and correct mime-type
  def data=(data)
    unless data.size == 0
      @data = data
      self.name = sanitize_filename(@data.original_filename)
      
      # Fix the mime types
      @data.content_type = MIME::Types.type_for(@data.original_filename).to_s
      self.content_type = @data.content_type.downcase.gsub(/[^a-z\-\/]/,"")
      self.file_type = self.determine_file_type
      
      self.set_dimensions
      self.size = @data.size
    end
    @data
  end

  def data
    @data
  end
  
  # The URL of the file
  # Uses Rails.application.routes to generate the URL
  #
  # @param size [String] The size to use for the filename  
  #
  # @options options [:cms, :preview, :published, nil] :mode The mode this URL is for. This option is required!
  def url(*args)
    options = args.extract_options!
    raise ArgumentError, ":mode option must be present, but can be nil" unless options.has_key?(:mode)
    
    size = args.first
    mode = options.delete(:mode) || :published
    
    url_options = {
      :action => "show",
      :file_id => self.id.to_s,
      :name => self.name,
      :only_path => true
    }
    
    if size && size = normalize_size(size)
      url_options[:size] = size.join("x")
    end
    
    case mode
    when :cms, :preview
      url_options.update({
        :controller => "skyline/media/data",
        :dir_id => self.parent_id.to_s
      })
      Skyline::Engine.routes.url_for(url_options)
    when :published
      self.add_allowed_size(size[0], size[1]) if size
      url_options.update({
        :controller => "skyline/site/media_files_data",  
        :cache_key => self.cache_key 
      })
      Rails.application.routes.url_for(url_options)
    end
  end
  
  
  # The key to use for caching, currently uses the 
  # updated_at, reversed and padded to six 0's
  #
  # @return [String]
  def cache_key
    s = self.updated_at.to_i.to_s.ljust(6,"0").reverse
    [s[0,2], s[2,2], s[4..-1]].join("/")
  end
  
  # Regex to check the size parameter
  SIZE_REGEX = /\A\d+x\d+\Z/
  
  def valid_size?(raw_size)
    raw_size =~ SIZE_REGEX
  end
  
  # Normalizes the size parameter
  #
  # @param size [String] A string with the format "AAAxBBB" where AAA and BBB are numbers.
  # @return [nil,false,Array[width,height]] Nil if no sizing should be done, false if this is just wrong and an array with [w,h] if it's ok.
  def normalize_size(raw_size)
    return nil unless raw_size.present? && self.resizable?
    if valid_size?(raw_size)
      size = raw_size.to_s.split("x").map{|v| v.to_i }
      
      # Unless all the sizes are set we have to assume this is crap and return an :unprocessable_entity 
      if !size.all?{|s| s > 0 }
        return false
      # No resizing if dimensions are larger than or equal to actual file
      elsif size[0] >= self.width && size[1] >= self.height
        return nil
      end
    else
      return false
    end
    size
  end
  
  # Check if a size is allowed for this file
  #
  # @param width [Integer] the width to check
  # @param height [Integer] the height to check
  #
  # @return [Boolean] whether the image should be rendered in the given size
  def allowed_size? (width, height)
    self.media_sizes.each do |size|
      return true if size.width == width && size.height == height
    end
    false
  end
  
  # Allow this file to be rendered in the given size
  def add_allowed_size(width, height)
    self.media_sizes.find_or_create_by_width_and_height(width, height)
  end
    
  
  def determine_file_type
    lookup = Mime::Type.lookup(self.content_type)
    lookup.instance_variable_get("@symbol").to_s
  end
  
  protected
  
  def set_dimensions
    return unless self.resizable?
    begin
      img = case self.data
      when ActionDispatch::Http::UploadedFile,Tempfile
        Magick::Image::read(self.data.path).first
      else
        Magick::Image::from_blob(self.data.read).first
        self.data.rewind        
      end
      
      self.width = img.columns
      self.height = img.rows
    rescue
    end
  end
  
  
  # Write data to disk
  def store_data
    return unless self.data.present?
    
    FileUtils.makedirs(File.dirname(self.file_path))
    tempfile = self.data.tempfile if self.data.respond_to?(:tempfile) && self.data.tempfile.present?
    if tempfile && !tempfile.respond_to?(:to_str) && tempfile.respond_to?(:each)
      File.open(self.file_path, "wb+"){|f| self.data.tempfile.each{|d| f.write(d) } }
      self.data.tempfile.close if self.data.tempfile.respond_to?(:close)
    else
      File.open(self.file_path, "wb+"){|f| f.write(self.data.read) }
    end
  end
  
  # Remove data from disk
  def remove_data
    File.unlink(self.file_path) if File.exist?(self.file_path)
  end 
  
  # reset ref objects that refer to removed media file
  # by setting referable_id = nil
  def reset_ref_object
    Skyline::RefObject.update_all({:referable_id => nil}, {:referable_id => self.id, :referable_type => self.class.name})    
  end
end
