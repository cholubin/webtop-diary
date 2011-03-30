# encoding: utf-8
require 'rubygems'
require 'carrierwave/orm/datamapper'   
require 'dm-core'
require 'dm-pager'

$:.unshift File.dirname(__FILE__) + '/../lib'

class Mytemplate
  
  # Class Configurations ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  include DataMapper::Resource
  
  # Attributes ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  property :id,                     Serial
  property :name,                   String
  property :path,                   String, :length => 200
  property :thumb_url,              String, :length => 200
  property :preview_url,            String, :length => 200  
  property :file_filename,          String, :length => 200
  property :type,                   String 
  property :description,            Text

  property :category,               String
  property :subcategory,            String
  property :temp_id,                String

  property :pdf,                    String, :length => 200     
  property :pdf_path,               String, :length => 200       
  property :folder,                 String, :default => "basic"
  property :order_fl,               Boolean, :default => false

  timestamps :at
  
  belongs_to :user
    
  before :create, :file_path

  def self.search(search, page)
      Mytemplate.all(:name.like => "%#{search}%").page :page => page, :per_page => 12
  end

  def self.search2(search, page)
      Mytemplate.all(:name.like => "%#{search}%").page :page => page, :per_page => 6
  end
  
  def self.in_order(order)
      Mytemplate.all(:order_fl => order)
  end

  def file_path   
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/pdfs/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir
    
    dir = "#{RAILS_ROOT}" + "/public/user_files/#{self.user.userid}/templates/"
    FileUtils.mkdir_p dir if not File.exist?(dir)
    FileUtils.chmod 0777, dir

    return dir 
  end  
    
end

DataMapper.auto_upgrade!

