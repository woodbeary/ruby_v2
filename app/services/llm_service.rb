# frozen_string_literal: true

require 'http'

class LlmService
  def self.classify_priority(title:, description:)
    begin
      self.broadcast_terminal("🔍 New incident received: '#{title}'")
      self.broadcast_terminal("📝 Preparing LLM prompt with incident context...")
      self.broadcast_terminal("🔧 Configuring request parameters: temperature=0.1, top_k=40")

      prompt = <<~PROMPT
        You are an IT incident priority classifier. Based on the incident details below, respond with ONLY P1, P2, P3, or P4.

        Severity Levels:
        P1 = CRITICAL: Complete system outages, all users affected
        P2 = HIGH: Major features broken, many users affected
        P3 = MEDIUM: Partial outages, some users affected
        P4 = LOW: Minor issues, few users affected

        Current Incident:
        Title: #{title}
        Description: #{description}

        Classify severity (respond with single priority level only):
      PROMPT

      Rails.logger.info "\nSending prompt to LLM:\n#{prompt}"
      endpoint = "http://23.242.121.228:8080/completion"

      self.broadcast_terminal("🤖 Establishing connection to JAI via HTTP...")
      self.broadcast_terminal("📡 Endpoint: 23.242.121.228:8080 (Local network)")
      
      response = HTTP.timeout(10).post(endpoint, json: {
        prompt: prompt,
        n_predict: 3,
        temperature: 0.1,
        stop: ["\n"],
        repeat_penalty: 1.2,
        top_k: 40,
        top_p: 0.95
      })
      
      if response.status.success?
        self.broadcast_terminal("✨ Response received from JAI")
        self.broadcast_terminal("🧠 Processing LLM output through classification logic...")
        
        data = JSON.parse(response.body.to_s)
        Rails.logger.info "\nRaw LLM response: #{data.inspect}"
        
        content = data['content'].to_s.strip
        Rails.logger.info "Raw content: #{content}"
        
        priority = if content.empty?
          Rails.logger.warn "Empty response received from LLM"
          determine_fallback_priority(title, description)
        elsif content.match?(/P[1-4]/)
          content.match(/P[1-4]/)[0]
        elsif content.match?(/[1-4]/)
          "P#{content.match(/[1-4]/)[0]}"
        else
          determine_fallback_priority(title, description)
        end

        Rails.logger.info "Final priority determined: #{priority}"
        self.broadcast_terminal("📊 Final priority determined: #{priority}")
        priority
      else
        handle_api_error(response)
      end
    rescue => e
      handle_exception(e)
    end
  end

  private

  def self.determine_fallback_priority(title, description)
    self.broadcast_terminal("⚠️ Using fallback priority logic...")
    
    combined_text = "#{title} #{description}".downcase
    
    case
    when combined_text.match?(/\b(down|outage|crash|broken|emergency|urgent)\b/)
      Rails.logger.info "=== Fallback analysis determined P1 ==="
      'P1'
    when combined_text.match?(/\b(error|issue|problem|bug|failed)\b/)
      Rails.logger.info "=== Fallback analysis determined P2 ==="
      'P2'
    when combined_text.match?(/\b(slow|delayed|minor|question)\b/)
      Rails.logger.info "=== Fallback analysis determined P4 ==="
      'P4'
    else
      Rails.logger.info "=== Defaulting to P3 ==="
      'P3'
    end
  end

  def self.handle_api_error(response)
    Rails.logger.error "API Error: #{response.status} - #{response.body}"
    self.broadcast_terminal("⚠️ API error: #{response.status}")
    determine_fallback_priority(title, description)
  end

  def self.handle_exception(error)
    Rails.logger.error "Exception: #{error.class} - #{error.message}"
    self.broadcast_terminal("❌ Error: #{error.class}")
    'P3'
  end

  def self.broadcast_terminal(message)
    Turbo::StreamsChannel.broadcast_update_to(
      "terminal",
      target: "terminal-updates",
      partial: "shared/terminal_message",
      locals: { message: message }
    )
  end
end 