class IncidentsController < ApplicationController
  before_action :set_incident, only: [:show, :edit, :update, :destroy]

  def index
    @incidents = Incident.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @incident = Incident.new
  end

  def create
    @incident = Incident.new(incident_params)
    
    if @incident.save
      broadcast_terminal("📝 New incident created (ID: #{@incident.id})")
      broadcast_terminal("🔒 Transaction committed to SQLite database")
      broadcast_terminal("🔄 Broadcasting Turbo Stream update to connected clients")
      
      # Immediately show loading state
      Turbo::StreamsChannel.broadcast_update_to(
        "incidents",
        target: "modal",
        partial: "incidents/analyzing_priority",
        locals: { incident: @incident }
      )

      # Process the LLM request
      recommended_priority = LlmService.classify_priority(
        title: @incident.title,
        description: @incident.description
      )
      
      # Show the recommendation
      Turbo::StreamsChannel.broadcast_update_to(
        "incidents",
        target: "modal",
        partial: "incidents/recommend_priority",
        locals: { incident: @incident, recommended_priority: recommended_priority }
      )

      # Render an empty response to complete the form submission
      head :ok
    else
      render :new, status: :unprocessable_entity
    end
  end

  def recommend_priority
    @recommended_priority = "P#{rand(1..5)}"
  end

  def update_priority
    @incident = Incident.find(params[:id])
    if @incident.update(priority: params[:priority])
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.prepend("incidents", partial: "incidents/incident", locals: { incident: @incident })
          ]
        }
        format.html { redirect_to @incident }
      end
    else
      redirect_to @incident, alert: 'Failed to update priority.'
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.update("modal", 
          partial: "incidents/edit_form", 
          locals: { incident: @incident }
        )
      }
    end
  end

  def update
    if @incident.update(incident_params)
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.replace(@incident, partial: "incidents/incident", locals: { incident: @incident })
          ]
        }
        format.html { redirect_to @incident, notice: 'Incident was successfully updated.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    broadcast_terminal("🗑️ Deleting incident ##{@incident.id}: '#{@incident.title}'")
    @incident.destroy
    broadcast_terminal("✓ Incident successfully removed from database")
    redirect_to incidents_url, notice: 'Incident was successfully deleted.'
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:title, :description, :priority, :status)
  end

  def broadcast_terminal(message)
    Turbo::StreamsChannel.broadcast_update_to(
      "terminal",
      target: "terminal-updates",
      partial: "shared/terminal_message",
      locals: { message: message }
    )
  end
end 