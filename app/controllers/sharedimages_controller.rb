# encoding: utf-8

class SharedimagesController < ApplicationController
    before_filter :authenticate_user!  
  # GET /myimages
  # GET /myimages.xml
  def index
    
    #확장자별 소팅
    ext = params[:ext]
    folder = params[:folder]
    
    category = params[:cate]
    subcategory = params[:subcate]
    
    @menu = "sharedimage"
    @board = "sharedimage"
    @section = "index"
    
    if Folder.all(:name => "photo", :user_id => current_user.id).count < 1
      folder = Folder.new()
      folder.name = "photo"
      folder.origin_name = "photo"
      folder.user_id = current_user.id
      
      if folder.save
        puts_message "photo folder just created!"
      end
    end
  
    if ext == "all" or ext == nil or ext == ""
      ext = "all"
    end
    
    if ext == "all" and folder == "all"
      @sharedimages = Sharedimage.all(:open_fl => true, :order => [:created_at.desc])                   
    elsif ext == "all" and folder != "all"
      @sharedimages = Sharedimage.all( :open_fl => true, :order => [:created_at.desc])
    elsif ext != "all" and folder == "all"
      @sharedimages = Sharedimage.all(:type => ext, :open_fl => true, :order => [:created_at.desc])
    elsif ext != "all" and folder != "all"
      @sharedimages = Sharedimage.all( :type => ext, :open_fl => true, :order => [:created_at.desc])
    end
    
    if category != nil and category != ""
      if subcategory != nil and subcategory != ""
        @sharedimages = @sharedimages.all(:category => category.to_i, :subcategory => subcategory.to_i)
      else
        @sharedimages = @sharedimages.all(:category => category.to_i)
      end
    end
    
    @sharedimages = @sharedimages.search_user(params[:search], params[:page])
    @categories = Category.all(:gubun => "image", :order => [:priority])
    @exts = repository(:default).adapter.select('SELECT distinct type FROM sharedimages where open_fl = \'t\'')
    
    @category = category
    @subcategory = subcategory
    
    render 'sharedimage'
    
    
  end

  # GET /myimages/1
  # GET /myimages/1.xml
  def show
    
    if signed_in?
      @menu = "sharedimage"      
      @board = "sharedimage"
      @section = "show"
        
      @sharedimage = Sharedimage.get(params[:id].to_i)
      @categories = Category.all(:gubun => "image", :order => [:priority])
      
        render 'sharedimage'

    else
      redirect_to '/login'
    end
  end
  
  def copy_to_myclipart
    puts_message "Copy to myclipart Start!"
    
    folder = params[:folder]
    shared_image_id = params[:image_id].to_i
    @sharedimage = Sharedimage.get(shared_image_id)
    
    @myimage = Myimage.new()
    @myimage.folder = folder
    @myimage.name = @sharedimage.name
    @myimage.description = @sharedimage.description
    @myimage.tags = @sharedimage.tags
    @myimage.type = @sharedimage.type
    @myimage.user_id = current_user.id

    
    if @myimage.save

      if @sharedimage.type == "eps" or @sharedimage.type == "pdf"
        thumb_type = "png"
      else
        thumb_type = "jpg"
      end
      
      @myimage.image_filename = @myimage.id.to_s + "." + @myimage.type
      @myimage.image_thumb_filename = @myimage.id.to_s + "." + thumb_type
      
      shared_path = "#{RAILS_ROOT}" + "/public/sharedimage/"
      myimage_path = "#{RAILS_ROOT}" + "/public/user_files/#{current_user.userid}/images/#{@myimage.folder}/"
      
      @myimage.make_thumb_folder(@myimage.folder)
      
      FileUtils.cp_r shared_path + @sharedimage.id.to_s + "." + @sharedimage.type, myimage_path + "#{@myimage.id.to_s}.#{@myimage.type}"
      FileUtils.cp_r shared_path + "Thumb/" + @sharedimage.id.to_s + "." + thumb_type, myimage_path + "Thumb/#{@myimage.id.to_s}.#{thumb_type}"
      FileUtils.cp_r shared_path + "Preview/" + @sharedimage.id.to_s + "." + thumb_type, myimage_path + "Preview/#{@myimage.id.to_s}.#{thumb_type}"
      
      if @myimage.save
        render :text => "success"
      else
        render :text => "DB저장실패!"
      end
    else
      puts_message @myimage.errors.to_s
      render :text => @myimage.errors.to_s
    end
    
  end
  
  def download_image
    sharedimage_id = params[:id].to_i
    @sharedimage = Sharedimage.get(sharedimage_id)
    
    if File.exists?("#{RAILS_ROOT}" + "/public/sharedimage/#{@sharedimage.id.to_s+"."+@sharedimage.type}")
      @sharedimage_path = "#{RAILS_ROOT}" + "/public/sharedimage/#{@sharedimage.id.to_s+"."+@sharedimage.type}"
      @type = "image/" + @sharedimage.type
  
      send_file @sharedimage_path, :filename => @sharedimage.name + "." + @sharedimage.type, :type => @type, :stream => "false", :disposition =>
      'attachment'
    end
  end

end
