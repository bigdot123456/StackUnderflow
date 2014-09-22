class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable
  before_action :find_comment, only: [:edit, :update, :destroy]
  before_action :comment_belongs_to_current_user?, only: [:edit, :update, :destroy]
  
  def create
    @comment = @commentable.comments.new(comment_params)

    if @comment.save
      current_user.comments << @comment
      flash[:success] = "Comment is created!"
    else
      flash[:danger] = "Invalid data! Comment length should be more than 10 symbols!"
    end
    redirect_to @commentable
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to @commentable, success: "Comment is edited!"
    else
      render "edit"
    end
  end

  def destroy
    @comment.destroy
    redirect_to @commentable, success: "Comment is deleted!"
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

    def find_commentable
      klass = [Question, Answer].detect { |c| params["#{c.name.underscore}_id"] }
      @commentable = klass.find(params[:question_id])
    end

    def find_comment
      @comment = @commentable.comments.find(params[:id])
    end

    def comment_belongs_to_current_user?
      unless @comment.user == current_user
        redirect_to @commentable
      end
    end
end
