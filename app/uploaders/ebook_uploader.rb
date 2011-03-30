class EbookUploader < CarrierWave::Uploader::Base

  storage :file

  def store_dir   
    "#{RAILS_ROOT}" + "/public/ebook"
  end
  
  def extension_white_list
      %w(zip)
  end

  def filename

    if original_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = File.extname(original_filename).downcase
      @file_name = original_filename.gsub(@file_ext_name,"")

      @temp_filename = model.id.to_s + @file_ext_name
    
      @temp_filename  
    end

  end

end
