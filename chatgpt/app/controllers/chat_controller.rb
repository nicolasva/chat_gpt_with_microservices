class ChatController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :init_service

  def index
    # vue principale
  end

  def chat
    session[:id] ||= SecureRandom.hex(8)
    user_message = params[:message]
    reply = @chatgpt.predict(user_message, session[:id])
    render json: { reply: reply }
  end

  private

  def init_service
    @chatgpt ||= ChatGptService.new
  end
end
