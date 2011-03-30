# encoding: utf-8

class EbooksController < ApplicationController
  def index
    
    @menu = "ebook"
    @board = "ebook"
    @section = "index"

    if params[:cate] != nil and params[:cate] != ""
      category = params[:cate]
    else
      category = "all"
    end
    
    if params[:subcate] != nil and params[:subcate] != ""
      subcategory = params[:subcate]
    else
      subcategory = "all"
    end
    
    if category != "all"
      @ebooks = Ebook.all(:category => category.to_i)
    else
      @ebooks = Ebook.all()
    end
    
    if subcategory != "all"
      @ebooks = @ebooks.all(:subcategory => subcategory.to_i)
    end
    
    @ebooks = @ebooks.search(params[:search], params[:page])      
    
    @categories = Category.all(:gubun => "ebook", :order => [:priority])

    render 'ebook'
  end

  def show
    @menu = "ebook"      
    @board = "ebook"
    @section = "show"
      
    @ebook = Ebook.get(params[:id])
    
    if @ebook.common == false
      if @ebook.user_id == current_user.id
        render 'ebook'
      else
        redirect_to '/'
      end
    else
      render 'ebook'
    end

  end


end
