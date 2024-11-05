class HomeController < ApplicationController
  def index
    @count = session[:count] || 0
  end

  def increment
    session[:count] = (session[:count] || 0) + 1
    
    render turbo_stream: turbo_stream.update(
      "click-count",
      session[:count].to_s
    )
  end
end 