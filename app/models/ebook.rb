# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Ebook

  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  mount_uploader :ebook_file, EbookUploader
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :ebook_file,         Text
  
  property :id,                 Serial
  property :original_filename,  String
  property :description,        String
  property :name,               String
  property :category,           Integer
  property :subcategory,        Integer

  timestamps :at

  before :create, :make_ebook_path


  def self.search(search, page)
      Ebook.all(:name.like => "%#{search}%").page :page => page, :per_page => 12
  end
  
  def make_ebook_path
    dir1 = "#{RAILS_ROOT}" + "/public/ebook/#{self.id.to_s}"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1

    dir1 = "#{RAILS_ROOT}" + "/public/ebook/Thumb"
    FileUtils.mkdir_p dir1 if not File.exist?(dir1)
    FileUtils.chmod 0777, dir1
  end  
  
  def ebook_path
    dir = "#{RAILS_ROOT}" + "/public/ebook/#{self.id.to_s}"
  end

  def path
    dir = "#{RAILS_ROOT}" + "/public/ebook"
  end
  
  def zipfile
    "#{RAILS_ROOT}" + "/public/ebook/#{self.id.to_s}.zip"
  end
  
  def thumb_url
    dir = "#{HOSTING_URL}" + "ebook/Thumb/#{self.id.to_s}.jpg"
  end

end

DataMapper.auto_upgrade!