# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Sharedimage
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :image_file, SharedimageUploader
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :image_file,                 Text,     :default => "no_image"
      
  property :id,                         Serial
  property :name,                       String
  property :description,                Text,     :lazy => [ :show ]
  property :tags,                       Text,     :lazy => [ :show ]
  property :type,                       String,   :default => "jpg"
  
  property :image_thumb_filename,       String
  property :category,                   Integer
  property :subcategory,                Integer
  
  property :open_fl,                    Boolean, :default => true

  timestamps :at
  
  before :create, :image_path

  
  def self.search_user(search, page)
      (Sharedimage.all(:name.like => "%#{search}%") | Sharedimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 12
  end

  def self.search(search, page)
      (Sharedimage.all(:name.like => "%#{search}%") | Sharedimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
  def self.open(open_fl)
      Sharedimage.all(:open_fl => open_fl)
  end
  
  
  def set_dir
      SharedimageUploader.store_dir = "#{RAILS_ROOT}" + "/public/sharedimage/images/"
  end
  
  def url
      "#{HOSTING_URL}" + "sharedimage/#{self.id.to_s}.#{self.type}"
  end
  

  def thumb_url
      "#{HOSTING_URL}" + "sharedimage/Thumb/#{self.image_thumb_filename}"
  end

  def preview_url
      "#{HOSTING_URL}" + "sharedimage/Preview/#{self.image_thumb_filename}"
  end

  def image_path

      dir1 = "#{RAILS_ROOT}" + "/public/sharedimage/Thumb"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1

      dir1 = "#{RAILS_ROOT}" + "/public/sharedimage/Preview"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1
  
    
      dir = "#{RAILS_ROOT}" + "/public/sharedimage/"
      FileUtils.mkdir_p dir if not File.exist?(dir)
      FileUtils.chmod 0777, dir

    return dir
  end
  
end

DataMapper.auto_upgrade!

