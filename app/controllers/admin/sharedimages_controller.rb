# encoding: utf-8
class Admin::SharedimagesController < ApplicationController
    layout 'admin_layout'
    before_filter :authenticate_admin!    
    
  # GET /myimages
  # GET /myimages.xml
  def index
      #확장자별 소팅
      ext = params[:ext]
      
      share = params[:share]
      if share != nil and share != "" and share != "all"
  			if share == "y"
  			  open_fl = true
  			else
  			  open_fl = false
			  end
  		else
  			share = "all"
  		end
  		
  		
      @menu = "board"
      @board = "sharedimage"
      @section = "index"

      if ext == "all" or ext == nil or ext == ""
        @sharedimages = Sharedimage.all(:order => [:created_at.desc])   
      else
        @sharedimages = Sharedimage.all(:type => ext, :order => [:created_at.desc])           
      end
      
      if params[:cate] != nil and params[:cate] != "" and params[:cate] != "all"
          if params[:subcate] != nil and params[:subcate] != ""
            @sharedimages = @sharedimages.all(:category => params[:cate].to_i, :subcategory => params[:subcate].to_i)
          else
            @sharedimages = @sharedimages.all(:category => params[:cate].to_i)
          end
      end
      
      
      if share != "all"
        @sharedimages = @sharedimages.open(open_fl).search_user(params[:search], params[:page])
        @total_count = @sharedimages.open(open_fl).search_user(params[:search], "").count
      else
        @sharedimages = @sharedimages.search_user(params[:search], params[:page])
        @total_count = @sharedimages.search_user(params[:search], "").count
      end

      @exts = repository(:default).adapter.select('SELECT distinct type FROM sharedimages')

      @categories = Category.all(:gubun => "image", :order => [:priority])
      render 'sharedimage'
      
  end


  def new
    @menu = "board"
    @board = "sharedimage"
    @section = "new"
  
    @categories = Category.all(:gubun => "image", :order => :priority)    
    @subcategories = Subcategory.all(:gubun => "image",:order => :priority)
  
    @sharedimage = Sharedimage.new
      
    render 'sharedimage'
  end

  # GET /myimages/1/edit
  def edit
    @sharedimage = Sharedimage.get(params[:id])

    @menu = "board"    
    @board = "sharedimage"
    @section = "edit"

    @folders = Folder.all(:user_id => current_user.id)
        
    render 'myimage'    
  end

  # POST /myimages
  # POST /myimages.xml
  def create
    @menu = "board"
    @board = "sharedimage"
    
    @sharedimage = Sharedimage.new(params[:sharedimage])

    image_path = @sharedimage.image_path
    SharedimageUploader.store_dir = @sharedimage.image_path
    
    # 이미지 업로드 처리 ===============================================================================
    if params[:sharedimage][:image_file] != nil

      @sharedimage.image_file = params[:sharedimage][:image_file]      

      puts_message params[:sharedimage][:image_file].original_filename
      
      ext_name = File.extname(params[:sharedimage][:image_file].original_filename)      
      file_name = params[:sharedimage][:image_file].original_filename.gsub(ext_name,'')
      
      @sharedimage.save
      
      if ext_name == ".eps" or ext_name == ".pdf"
         @sharedimage.image_thumb_filename = @sharedimage.id.to_s + ".png"
       else
         @sharedimage.image_thumb_filename = @sharedimage.id.to_s + ".jpg"
       end
       
      #검색시 필터로 사용할 타입 설정
      @sharedimage.type = ext_name.gsub(".",'').downcase 
             
       # 중복파일명 처리 ===============================================================================

      if params[:sharedimage][:name] == ""
        @sharedimage.name = file_name
      end

      
      if @sharedimage.save  
         # image filename renaming ======================================================================
         
         
       ext_name_up = @sharedimage.type
       file_name_up = @sharedimage.id.to_s
       
       filename = file_name_up + "." + ext_name_up
        if  File.exist?(image_path + "/" + filename)
        	image_folder = "#{RAILS_ROOT}" + "/public/sharedimage"
      	  if ext_name_up == "eps" or ext_name_up == "pdf"
      	    puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_folder + "/" + filename} #{image_folder + "/preview/" + file_name_up + ".png"} 0.5 #{image_folder + "/thumb/" + file_name_up + ".png"} 128]            	  
      	  else
      	    puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_folder + "/" + filename} #{image_folder + "/preview/" + file_name_up + ".jpg"} 0.5 #{image_folder + "/thumb/" + file_name_up + ".jpg"} 128]            	  
      	  end
        end

         # image filename renaming ======================================================================
         @sharedimages = Sharedimage.all(:order => [:created_at.desc]).search_user(params[:search], params[:page])   
         @total_count = @sharedimages.count
         @exts = repository(:default).adapter.select('SELECT distinct type FROM sharedimages')
         
         redirect_to admin_sharedimages_url, :object=>@sharedimages, :object=>@total_count
       else
         puts_message @sharedimage.errors.to_s
         @section = "new"
         render 'sharedimage'
       end

    else
          flash[:notice] = '이미지는 반드시 선택하셔야 합니다.'      
          @section = "new"
          render 'sharedimage'
    end

  end

  # PUT /myimages/1
  # PUT /myimages/1.xml
  def update
    
    #레이아웃 관련 변수 
    @menu = "mytemplate"    
    @board = "myimage"
    @section = "edit"

    #페이징 관련 변수 
    search = params[:search]
    ext = params[:ext]

    #모델관련 변수 
    @sharedimage = Sharedimage.get(params[:id])
    @sharedimage.name = params[:myimage][:name]
    @sharedimage.description = params[:myimage][:description]
    new_folder_name = params[:myimage][:folder]
    old_folder_name = @sharedimage.folder
    @sharedimage.folder = new_folder_name
    
    image_path_basic = @sharedimage.image_path                          # 기본 이미지폴더 (photo)
    image_path_new_folder = @sharedimage.image_folder(new_folder_name)  # 변경될 폴더 
    image_path_old_folder = @sharedimage.image_folder(old_folder_name)  # 기존 폴더     
    
          
    ext_name = File.extname(@sharedimage.image_filename)
    file_name = @sharedimage.image_filename.gsub(ext_name,'')

    #파일명의 확장자로 판단하여 타입결정
    @sharedimage.type = ext_name.gsub('.','').downcase

    #이미지를 변경하는 경우 
    if params[:myimage][:image_file] != nil
      #먼저 기존에 업로드된 이미지를 삭제한다.
      if !@sharedimage.image_path.nil? && !@sharedimage.image_filename.nil?
        if  File.exist?(image_path_old_folder + "/" + @sharedimage.image_filename)
          #오리지날 파일 삭제
      	  File.delete(image_path_old_folder + "/" + @sharedimage.image_filename)         #original image file      
      	  # 썸네일 삭제
      	  if File.exist?(image_path_old_folder + "/thumb/" + @sharedimage.image_filename)
      	    File.delete(image_path_old_folder + "/thumb/" + @sharedimage.image_filename)         #original image file
      	  end
      	  # 프리뷰 삭제
      	  if File.exist?(image_path_old_folder + "/preview/" + @sharedimage.image_filename)
            File.delete(image_path_old_folder + "/preview/" + @sharedimage.image_filename)   #thumbnail image file  	  
          end
      	end
    	end
    	
    	#새로운 이미지파일을 업로드 한다.
      @sharedimage.image_file = params[:myimage][:image_file]      
      @temp_filename = sanitize_filename(params[:myimage][:image_file].original_filename)

      # 중복파일명 처리 ===============================================================================
      # 중복체크는 기본폴더(photo)에서 한 후 목표 폴더로 이동처리 한다. (캐리어웨이브 제약조건 때문.)
      while File.exist?(image_path_basic + "/" + @temp_filename) 
        @temp_filename = @temp_filename.gsub(File.extname(@temp_filename),"") + "_1" + File.extname(@temp_filename)
        @sharedimage.image_filename = @temp_filename
      end 
      @sharedimage.image_filename = @temp_filename
      @sharedimage.image_thumb_filename = @temp_filename
      # 중복파일명 처리 ===============================================================================

      @sharedimage.image_filename_encoded = @sharedimage.image_file.filename    	
    end

    if @sharedimage.save
      if @temp_filename != nil
        file_name = @sharedimage.image_filename.gsub(File.extname(@temp_filename),"")
      else
        file_name = @sharedimage.image_filename.gsub(ext_name,"")        
      end

      #파일을 새롭게 업로드하는 경우 
      if params[:myimage][:image_file] != nil
    	  File.rename image_path_basic + "/" + @sharedimage.image_filename_encoded, image_path_new_folder  + "/" + @sharedimage.image_filename #original file
    	  #썸네일생성 
    	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{image_path_new_folder + "/" + @sharedimage.image_filename} #{image_path_new_folder + "/preview/" + file_name + ".jpg"} 0.5 #{image_path_new_folder + "/thumb/" + file_name + ".jpg"} 128]            	  

      #폴더만 변경하는 경우 
      else
        puts "====================================================================="
        puts image_path_old_folder + "/" + @sharedimage.image_filename
        puts "====================================================================="        
    	  File.rename image_path_old_folder + "/" + @sharedimage.image_filename, image_path_new_folder  + "/" + @sharedimage.image_filename #original file
    	  File.rename image_path_old_folder + "/Preview/" + file_name + ".jpg", image_path_new_folder  + "/Preview/" + file_name + ".jpg" #original file
    	  File.rename image_path_old_folder + "/Thumb/" + file_name + ".jpg", image_path_new_folder  + "/Thumb/" + file_name + ".jpg" #original file
      end
      
      redirect_to '/admin/sharedimages?search='+search+'&ext='+ext
    else
      render 'sharedimage'
    end


  end
  # GET /myimages/1
  # GET /myimages/1.xml
  def show
      @sharedimage = Sharedimage.get(params[:id].to_i)
      
      @menu = "board"
      @board = "sharedimage"
      @section = "show"
            
      render 'sharedimage'

  end

  # DELETE /myimages/1
  # DELETE /myimages/1.xml
  def destroy
    @sharedimage = Sharedimage.get(params[:id])
    ext_name_up = File.extname(@sharedimage.image_filename_encoded)
    filename = @sharedimage.image_filename_encoded.gsub(ext_name_up,"")
    
    if ext_name_up == ".eps" or ext_name_up == ".pdf"
      ext_name = ".png"
    else
      ext_name = ".jpg"
    end
    
    if  File.exist?(@sharedimage.image_path + @sharedimage.image_filename_encoded)
  	  File.delete(@sharedimage.image_path + @sharedimage.image_filename_encoded)         #original image file
      File.delete(@sharedimage.image_path + "Thumb/" + filename + ext_name)   #thumbnail image file  	  
      File.delete(@sharedimage.image_path + "Preview/" + filename + ext_name)   #thumbnail image file  	  
  	end
  	
    @sharedimage.destroy

    @menu = "myimage"
    @board = "myimage"
    @section = "index"
    
    # @sharedimages = Sharedimage.all(:common => true, :order => [:created_at.desc])
    # @total_count = @sharedimages.count
    # @exts = repository(:default).adapter.select('SELECT distinct type FROM myimages where common = \'t\'')
    
    redirect_to '/admin/myimages'
  end
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @sharedimage = Sharedimage.get(chk[0].to_i)
        ext_name_up = @sharedimage.type
        filename = @sharedimage.id.to_s + "." + @sharedimage.type

        if ext_name_up == "eps" or ext_name_up == "pdf"
          ext_name = ".png"
        else
          ext_name = ".jpg"
        end
        
        begin         
          puts_message "hefe" +  @sharedimage.image_path + "Thumb/" + @sharedimage.id.to_s +  ext_name
          
          if  File.exist?(@sharedimage.image_path + filename)
        	  File.delete(@sharedimage.image_path + filename)         #original image file
            File.delete(@sharedimage.image_path + "Thumb/" + @sharedimage.id.to_s + ext_name)   #thumbnail image file  	  
            File.delete(@sharedimage.image_path + "Preview/" + @sharedimage.id.to_s + ext_name)   #thumbnail image file  
            
            	  
        	end
        rescue
          puts_message "파일삭제 실패!"
        end
      	
        @sharedimage.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    @menu = "board"
    @board = "sharedimage"
    @section = "index"

    redirect_to '/admin/sharedimages'
   end

   def category_update
     
     @categories = Category.all(:gubun => "image")
     
     render :update do |page|
       page.replace_html 'categories', :partial => 'categories', :object => @categories
     end
     
   end
   
   def update_subcategories
        categories = Category.get(params[:category_id].to_i)
        subcategories = categories.subcategories.all(:order => :priority)

        puts_message subcategories.count.to_s
        # puts subcategories.inspect

        render :update do |page|
          page.replace_html 'subcategories', :partial => 'subcategories', :object => subcategories
        end
    end
  
  def category_change_update
    @sharedimage = Sharedimage.get(params[:id].to_i)
    @sharedimage.category = params[:value].to_i
    
    category = Category.get(params[:value].to_i)
    @subcategories = category.subcategories.all(:order => :priority)
    
    @sharedimage.subcategory = category.subcategories.first(:order => :priority).id
    
    if @sharedimage.save
      
      puts_message @subcategories.count.to_s
      # puts subcategories.inspect

      render :update do |page|
        page.replace_html 'subcategories_'+ params[:id], :partial => 'subcategories', :object => @subcategories, :object => @sharedimage
      end
    else
      puts_message @sharedimage.errors.to_s
      render :text => "fail"
    end
    
  end
  
  def subcategory_change_update
    sharedimage = Sharedimage.get(params[:id].to_i)
    sharedimage.subcategory = params[:value].to_i
    
    if sharedimage.save
      render :text => "success"
    else
      render :text => "fail"
    end 
  end
  
  def change_open_status
    id = params[:id]
    sharedimage = Sharedimage.get(id)
    
    sharedimage.open_fl = !sharedimage.open_fl
    
    if sharedimage.save
      render :text => "success"
    else
      render :text => "fail"
    end
  end
  
  def change_subject
    id = params[:id]
    sharedimage = Sharedimage.get(id)
    sharedimage.name = params[:str]
    
    if sharedimage.save
      render :text => "success"
    else
      render :text => "fail"
    end
    
  end
end
