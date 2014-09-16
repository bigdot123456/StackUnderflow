class AnswersController < ApplicationController

	before_action :must_be_logged_in, except: [ :show ]

	def create
		@question = Question.find(params[:question_id])
		@answer = @question.answers.new(answer_params)

		if @answer.save
			current_user.answers << @answer
			flash[:success] = "Answer is created!"
		else
			flash[:danger] = "Wrong length of answer!"
		end
		redirect_to @question
	end

	def show
		@question = Question.find(params[:question_id])
		@answers = @question.answers
		@answer = Answer.new
		render "questions#show"
	end

	def edit
		@answer = Answer.find(params[:id])
	end

	def update
		@answer = Answer.find(params[:id])

		if @answer.update(answer_params)
			flash[:success] = "Answer is updated!"
			redirect_to question_path(@answer.question.id)
		else
			render "edit"
		end
	end

	def destroy
		@answer = current_user.answers.find(params[:id])
		@answer.destroy
		flash[:success] = "Answer is deleted!"
		redirect_to root_path
	end

	def mark_best
		@answer = Answer.find(params[:id])
		@answer.mark_best!
		flash[:success] = "Answer marked as best!"
		redirect_to @answer.question
	end

	private
		
		def answer_params
			params.require(:answer).permit(:body)
		end

		def must_be_logged_in
			unless user_signed_in?
				flash[:danger] = "You must be logged in."
				redirect_to root_path
			end
		end
end