module TaskMicroservice
  def self.update(task_id, new_task_status_id, token)

    conn = Faraday.new(url: "http://127.0.0.1:3001") do |faraday|
      faraday.request :authorization, :Bearer, token
      faraday.adapter Faraday.default_adapter
    end

    body = { id: task_id, task_status_id: new_task_status_id }.to_json

    response = conn.patch("/edit_task", body, 'Content-Type' => 'application/json')

    response
  end
end