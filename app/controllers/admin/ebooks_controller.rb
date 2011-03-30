  # encoding: utf-8
class Admin::EbooksController < ApplicationController
    layout 'admin_layout'
    before_filter :authenticate_admin!    
    
  # GET /ebooks
  # GET /ebooks.xml
  def index
      @menu = "board"
      @board = "ebook"
      @section = "index"

      @ebooks = Ebook.all()
      
      if params[:cate] != nil and params[:cate] != "" and params[:cate] != "all"
        if params[:subcate] != nil and params[:subcate] != ""
          @ebooks = @ebooks.all(:category => params[:cate].to_i, :subcategory => params[:subcate].to_i)
        else
          @ebooks = @ebooks.all(:category => params[:cate].to_i)
        end
      end
      
      
      @ebooks = @ebooks.search(params[:search], params[:page])
      @total_count = @ebooks.search(params[:search], "").count


      @categories = Category.all(:gubun => "ebook", :order => [:priority])
      
      render 'ebook'
      
  end


  def new
    @menu = "board"
    @board = "ebook"
    @section = "new"
  
    @categories = Category.all(:gubun => "ebook", :order => :priority)    
    @subcategories = Subcategory.all(:gubun => "ebook",:order => :priority)
  
    @ebook = Ebook.new
      
    render 'ebook'
  end

  # GET /ebooks/1/edit
  def edit
    @ebook = Ebook.get(params[:id])

    @menu = "board"    
    @board = "ebook"
    @section = "edit"

    render 'ebook'    
  end

  # POST /ebooks
  # POST /ebooks.xml
  def create
    @menu = "board"
    @board = "ebook"
    
    @ebook = Ebook.new(params[:ebook])
    ebook_path = @ebook.ebook_path
    EbookUploader.store_dir = @ebook.ebook_path
    
    # 이미지 업로드 처리 ===============================================================================
    if params[:ebook][:ebook_file] != nil

      @ebook.ebook_file = params[:ebook][:ebook_file]      
      @ebook.original_filename = params[:ebook][:ebook_file].original_filename.gsub(".zip","")
      puts_message params[:ebook][:ebook_file].original_filename
      
      ext_name = File.extname(params[:ebook][:ebook_file].original_filename)      
      file_name = params[:ebook][:ebook_file].original_filename.gsub(ext_name,'')
      
       # 중복파일명 처리 ===============================================================================

      if params[:ebook][:name] == ""
        @ebook.name = file_name
      end

      if @ebook.save  
       
        @ebooks = Ebook.all(:order => [:created_at.desc]).search(params[:search], params[:page])   
        @total_count = @ebooks.count
        
        unzip_uploaded_file(@ebook)

        redirect_to admin_ebooks_url, :object=>@ebooks, :object=>@total_count
       else
         puts_message @ebook.errors.to_s
         @section = "new"
         render 'ebook'
       end

    else
          flash[:notice] = '이미지는 반드시 선택하셔야 합니다.'      
          @section = "new"
          render 'ebook'
    end

  end
  
  def unzip_uploaded_file(ebook) 
   if ebook != nil   
     destination = ebook.path + "/#{ebook.id.to_s}"
     
     begin
       FileUtils.mkdir_p destination if not File.exist?(destination)
       FileUtils.chmod 0777, destination
      rescue
        puts_message "ebook folder creation was failed!"
      end
     
     # puts_message destination 
     
     loop do 
        break if File.exists?(ebook.path + "/" + ebook.id.to_s + ".zip")
     end
     
       unzip(ebook, destination)    
     end
   end

   def unzip(ebook, destination)  
         file = ebook.zipfile
         
         system "cd #{ebook.ebook_path}; unzip #{ebook.zipfile}"
         # puts file
          original_filename = (ebook.original_filename.force_encoding("UTF-8"))
          
          Zip::ZipFile.open(file) { |zip_file|
            zip_file.each{ |f| 
              f_path = File.join(destination, f.name.force_encoding("UTF-8"))
              # puts_message "here:::" +  destination
              # puts_message "here:::" +  f.name
              f_path = f_path.gsub(/\/{1}[\sa-zA-Z0-9\w]*\.mBook/,"")
          
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            }
          }

         FileUtils.rm_rf (destination + "/__MACOSX")
         system "cp #{ebook.ebook_path}/images/page1_thumbnail.jpg #{ebook.path}/Thumb/#{ebook.id.to_s}.jpg"
    end
  # PUT /ebooks/1
  # PUT /ebooks/1.xml
  def update
    
    #레이아웃 관련 변수 
    @menu = "board"    
    @board = "ebook"
    @section = "edit"

    #페이징 관련 변수 
    search = params[:search]
    ext = params[:ext]

    #모델관련 변수 
    @ebook = Ebook.get(params[:id])
    @ebook.name = params[:ebook][:name]
    @ebook.description = params[:ebook][:description]
    new_folder_name = params[:ebook][:folder]
    old_folder_name = @ebook.folder
    @ebook.folder = new_folder_name
    
    ebook_path_basic = @ebook.ebook_path                          # 기본 이미지폴더 (photo)
    ebook_path_new_folder = @ebook.image_folder(new_folder_name)  # 변경될 폴더 
    ebook_path_old_folder = @ebook.image_folder(old_folder_name)  # 기존 폴더     
    
          
    ext_name = File.extname(@ebook.ebook_filename)
    file_name = @ebook.ebook_filename.gsub(ext_name,'')

    #파일명의 확장자로 판단하여 타입결정
    @ebook.type = ext_name.gsub('.','').downcase

    #이미지를 변경하는 경우 
    if params[:ebook][:ebook_file] != nil
      #먼저 기존에 업로드된 이미지를 삭제한다.
      if !@ebook.ebook_path.nil? && !@ebook.ebook_filename.nil?
        if  File.exist?(ebook_path_old_folder + "/" + @ebook.ebook_filename)
          #오리지날 파일 삭제
      	  File.delete(ebook_path_old_folder + "/" + @ebook.ebook_filename)         #original image file      
      	  # 썸네일 삭제
      	  if File.exist?(ebook_path_old_folder + "/thumb/" + @ebook.ebook_filename)
      	    File.delete(ebook_path_old_folder + "/thumb/" + @ebook.ebook_filename)         #original image file
      	  end
      	  # 프리뷰 삭제
      	  if File.exist?(ebook_path_old_folder + "/preview/" + @ebook.ebook_filename)
            File.delete(ebook_path_old_folder + "/preview/" + @ebook.ebook_filename)   #thumbnail image file  	  
          end
      	end
    	end
    	
    	#새로운 이미지파일을 업로드 한다.
      @ebook.ebook_file = params[:ebook][:ebook_file]      
      @temp_filename = sanitize_filename(params[:ebook][:ebook_file].original_filename)

      # 중복파일명 처리 ===============================================================================
      # 중복체크는 기본폴더(photo)에서 한 후 목표 폴더로 이동처리 한다. (캐리어웨이브 제약조건 때문.)
      while File.exist?(ebook_path_basic + "/" + @temp_filename) 
        @temp_filename = @temp_filename.gsub(File.extname(@temp_filename),"") + "_1" + File.extname(@temp_filename)
        @ebook.ebook_filename = @temp_filename
      end 
      @ebook.ebook_filename = @temp_filename
      @ebook.image_thumb_filename = @temp_filename
      # 중복파일명 처리 ===============================================================================

      @ebook.ebook_filename_encoded = @ebook.ebook_file.filename    	
    end

    if @ebook.save
      if @temp_filename != nil
        file_name = @ebook.ebook_filename.gsub(File.extname(@temp_filename),"")
      else
        file_name = @ebook.ebook_filename.gsub(ext_name,"")        
      end

      #파일을 새롭게 업로드하는 경우 
      if params[:ebook][:ebook_file] != nil
    	  File.rename ebook_path_basic + "/" + @ebook.ebook_filename_encoded, ebook_path_new_folder  + "/" + @ebook.ebook_filename #original file
    	  #썸네일생성 
    	  puts %x[#{RAILS_ROOT}"/lib/thumbup" #{ebook_path_new_folder + "/" + @ebook.ebook_filename} #{ebook_path_new_folder + "/preview/" + file_name + ".jpg"} 0.5 #{ebook_path_new_folder + "/thumb/" + file_name + ".jpg"} 128]            	  

      #폴더만 변경하는 경우 
      else
        puts "====================================================================="
        puts ebook_path_old_folder + "/" + @ebook.ebook_filename
        puts "====================================================================="        
    	  File.rename ebook_path_old_folder + "/" + @ebook.ebook_filename, ebook_path_new_folder  + "/" + @ebook.ebook_filename #original file
    	  File.rename ebook_path_old_folder + "/Preview/" + file_name + ".jpg", ebook_path_new_folder  + "/Preview/" + file_name + ".jpg" #original file
    	  File.rename ebook_path_old_folder + "/Thumb/" + file_name + ".jpg", ebook_path_new_folder  + "/Thumb/" + file_name + ".jpg" #original file
      end
      
      redirect_to '/admin/ebooks?search='+search+'&ext='+ext
    else
      render 'ebook'
    end


  end
  # GET /ebooks/1
  # GET /ebooks/1.xml
  def show
      @ebook = Ebook.get(params[:id].to_i)
      
      @menu = "board"
      @board = "ebook"
      @section = "show"
            
      render 'ebook'

  end

  # DELETE /ebooks/1
  # DELETE /ebooks/1.xml
  def destroy
    @ebook = Ebook.get(params[:id])
    ext_name_up = File.extname(@ebook.ebook_filename_encoded)
    filename = @ebook.ebook_filename_encoded.gsub(ext_name_up,"")
    
    if ext_name_up == ".eps" or ext_name_up == ".pdf"
      ext_name = ".png"
    else
      ext_name = ".jpg"
    end
    
    if  File.exist?(@ebook.ebook_path + @ebook.ebook_filename_encoded)
  	  File.delete(@ebook.ebook_path + @ebook.ebook_filename_encoded)         #original image file
      File.delete(@ebook.ebook_path + "Thumb/" + filename + ext_name)   #thumbnail image file  	  
      File.delete(@ebook.ebook_path + "Preview/" + filename + ext_name)   #thumbnail image file  	  
  	end
  	
    @ebook.destroy

    @menu = "ebook"
    @board = "ebook"
    @section = "index"
    
    # @ebooks = Ebook.all(:common => true, :order => [:created_at.desc])
    # @total_count = @ebooks.count
    # @exts = repository(:default).adapter.select('SELECT distinct type FROM ebooks where common = \'t\'')
    
    redirect_to '/admin/ebooks'
  end
  
  # multiple deletion
  def deleteSelection 

    chk = params[:chk]

    if !chk.nil? 
      chk.each do |chk|
        @ebook = Ebook.get(chk[0].to_i)
        
        begin         
          if File.exist?(@ebook.ebook_path + ".zip")
        	  File.delete(@ebook.ebook_path + ".zip")         #original image file
            File.delete(@ebook.path + "/Thumb/" + @ebook.id.to_s + ".jpg")   #thumbnail image file  	  
            FileUtils.rm_rf(@ebook.ebook_path)
        	end
        rescue
          puts_message "파일삭제 실패!"
        end
      	
        @ebook.destroy    
      end
    else
        flash[:notice] = '삭제할 글을 선택하지 않으셨습니다!'    
    end
      
    @menu = "board"
    @board = "ebook"
    @section = "index"

    redirect_to '/admin/ebooks'
   end

   def update_subcategories
        categories = Category.get(params[:category_id].to_i)
        subcategories = categories.subcategories.all(:gubun => "ebook", :order => :priority)

        puts_message subcategories.count.to_s
        # puts subcategories.inspect

        render :update do |page|
          page.replace_html 'subcategories', :partial => 'subcategories', :object => subcategories
        end
    end
  
   def category_update

     @categories = Category.all(:gubun => "ebook")

     render :update do |page|
       page.replace_html 'categories', :partial => 'categories', :object => @categories
     end

   end
     
  def category_change_update
    @ebook = Ebook.get(params[:id].to_i)
    @ebook.category = params[:value].to_i
    
    category = Category.get(params[:value].to_i)
    @subcategories = category.subcategories.all(:gubun => "ebook", :order => :priority)
    
    if category.subcategories.first(:gubun => "ebook", :order => :priority) != nil
      @ebook.subcategory = category.subcategories.first(:gubun => "ebook", :order => :priority).id
    else
      @ebook.subcategory = nil
    end
    
    if @ebook.save
      
      puts_message @subcategories.count.to_s
      # puts subcategories.inspect

      render :update do |page|
        page.replace_html 'subcategories_'+ params[:id], :partial => 'subcategories', :object => @subcategories, :object => @ebook
      end
    else
      puts_message @ebook.errors.to_s
      render :text => "fail"
    end
    
  end
  
  def subcategory_change_update
    ebook = Ebook.get(params[:id].to_i)
    if params[:value] != nil and params[:value] != ""
      ebook.subcategory = params[:value].to_i
    else
      ebook.subcategory = nil
    end
    
    if ebook.save
      render :text => "success"
    else
      render :text => "fail"
    end 
  end
  
  def change_open_status
    id = params[:id]
    ebook = Ebook.get(id)
    
    ebook.open_fl = !ebook.open_fl
    
    if ebook.save
      render :text => "success"
    else
      render :text => "fail"
    end
  end
  
  def change_subject
    id = params[:id]
    ebook = Ebook.get(id)
    ebook.name = params[:str]
    
    if ebook.save
      render :text => "success"
    else
      render :text => "fail"
    end
    
  end
end
