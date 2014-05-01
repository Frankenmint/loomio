collection @events, :object_root => false
attributes :id, :user_id, :kind, :eventable_type, :eventable_id
node :group_id do |event|
  if event.eventable.present? and event.eventable.respond_to?(:group_id)
    event.eventable.group_id
  end
end
node :eventable do |event|
  if event.eventable
    partial('admin/stats/'+event.eventable.class.to_s.underscore, object: event.eventable)
  end
end
