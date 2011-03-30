class SharedimageUploader < CarrierWave::Uploader::Base

  storage :file

  def extension_white_list
      %w(jpg jpeg gif png pdf eps tif)
  end

  def filename

    if original_filename # 이미지파일을 업로드 한 경우에만 적용 
      @file_ext_name = File.extname(original_filename).downcase
      @file_name = model.id.to_s

      @temp_filename = @file_name + @file_ext_name
    
      @temp_filename
    end

  end

end
