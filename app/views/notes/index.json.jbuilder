json.array!(@notes) do |note|
  json.extract! note, :id, :name, :details, :task_id
  json.url note_url(note, format: :json)
end
