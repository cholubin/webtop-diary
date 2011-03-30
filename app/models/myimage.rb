# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Myimage
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :image_file, MyimageUploader
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :image_file,                 Text,     :default => "no_image"
  property :image_filename,             String,   :length => 200  
  property :image_thumb_filename,       String,   :length => 200    
  property :image_filename_encoded,     String,   :length => 200
      
  property :id,                         Serial
  property :name,                       String
  property :description,                Text,     :lazy => [ :show ]
  property :tags,                       Text,     :lazy => [ :show ]
  property :type,                       String,   :default => "jpg"
  
  property :folder,                     String,   :default => "photo"
  property :common,                     Boolean,  :default => false
  property :admin_id,                   Integer
  
  property :open_fl,                    Boolean, :default => false

  timestamps :at
  
  belongs_to :user
  before :create, :image_path

  
  def self.search_user(search, page)
      (Myimage.all(:name.like => "%#{search}%") | Myimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 12
  end

  def self.search(search, page)
      (Myimage.all(:name.like => "%#{search}%") | Myimage.all(:tags.like => "%#{search}%")).page :page => page, :per_page => 10
  end
  
  def self.open(open_fl)
      Myimage.all(:open_fl => open_fl)
  end
  
  
  def set_dir
    if not self.user.nil?
      MyimageUploader.store_dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/"
    end
  end
  
  def url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/#{self.id.to_s}.#{self.type}"
    end
  end
  
  def admin_url
    "#{HOSTING_URL}" + "basic_photo/#{self.id.to_s}.#{self.type}"
  end
  

  def thumb_url
    if not self.user.nil?
      if self.type == "pdf" or self.type == "eps"
        "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/Thumb/#{self.image_thumb_filename}"
      else
        "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/Thumb/#{self.image_thumb_filename}"
      end
    end
  end

  def thumb_admin_url
    ext_name_up = File.extname(self.image_filename_encoded)
    filename = self.image_filename_encoded.gsub(ext_name_up,"")
    
    if ext_name_up == ".eps" or ext_name_up == ".pdf"
      ext_name = ".png"
    else
      ext_name = ".jpg"
    end
      
    "#{HOSTING_URL}" + "basic_photo/Thumb/#{self.id.to_s+ext_name}"
    
  end
  
  def preview_url
    if not self.user.nil?
      "#{HOSTING_URL}" + "user_files/#{self.user.userid}/images/#{self.folder}/Preview/#{self.image_thumb_filename}"
    end
  end

  def preview_admin_url
    ext_name_up = File.extname(self.image_filename_encoded)
    filename = self.image_filename_encoded.gsub(ext_name_up,"")
    
    if ext_name_up == ".eps" or ext_name_up == ".pdf"
      ext_name = ".png"
    else
      ext_name = ".jpg"
    end
    
    "#{HOSTING_URL}" + "basic_photo/Preview/#{self.id.to_s+ext_name}"
  end
  
  def make_thumb_folder(folder)
    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Thumb"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Preview"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1
  end
  
  def image_path

    if self.user != nil
      dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo/Thumb"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1

      dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo/Preview"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1
  
    
      dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/photo"
      FileUtils.mkdir_p dir if not File.exist?(dir)
      FileUtils.chmod 0777, dir

    else
      dir1 = "#{RAILS_ROOT}" + "/public/basic_photo/Thumb"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1

      dir1 = "#{RAILS_ROOT}" + "/public/basic_photo/Preview"
      FileUtils.mkdir_p dir1 if not File.exist?(dir1)
      FileUtils.chmod 0777, dir1

      dir = "#{RAILS_ROOT}" + "/public/basic_photo"
      FileUtils.mkdir_p dir if not File.exist?(dir)
      FileUtils.chmod 0777, dir
    end
    
    return dir
  end
  
  def image_admin_path

    dir1 = "#{RAILS_ROOT}" + "/public/basic_photo/Thumb/"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/basic_photo/Preview/"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir = "#{RAILS_ROOT}" + "/public/basic_photo/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    return dir
  end

  
  def image_folder(folder)
    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Thumb"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/Preview"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1
  
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/images/#{folder}/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    return dir 
  end


      
end

DataMapper.auto_upgrade!

