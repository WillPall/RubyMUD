#!/usr/bin/env ruby

require File.expand_path('../config/ruby_mud', __FILE__)
require 'sinatra'

RubyMUD.initialize

db_config = YAML.load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_config)

RubyMUD.game.prepare_game_state
RubyMUD.game.load_world

set :views, settings.root + '/lib/editor/views'
set :public_folder, settings.root + '/lib/editor/public'
set :bind, '0.0.0.0'
set :port, 34911

get '/' do
  @items = Items::Item.all
  @starting_room = Area.first.starting_room
  erb :index
end

get '/areas' do
  Area.all.to_json(include: {rooms: {include: :connections}})
end

get '/area_map/:id' do
  area = Area.find(params[:id])
  map_html = ''
  area.map(padding: 6).each_with_index do |row, y|
    map_html += '<div>'
    
    row.each_with_index do |col, x|
      if col.present?
        map_html += "<div class=\"area-room area-room--#{col.room_type.map_color} #{col.room_type.map_is_bright? ? 'area-room--bright' : ''}\" data-id=\"#{col.id}\" data-x=\"#{col.x}\" data-y=\"#{col.y}\">#{col.room_type.map_character}</div>"
      else
        map_html += "<div class=\"area-room area-room--empty\" data-x=\"#{x - 6}\" data-y=\"#{y - 6}\"></div>"
      end
    end

    map_html += '</div>'
  end

  map_html
end

post '/rooms' do
  room = nil

  if params[:id].present?
    room = Room.find(params[:id])
    room.update(params)
  else
    room_type = RoomType.find(params[:room_type_id])
    room = Room.new(params.except(:id))
    room.save
  end

  room.to_json(include: :connections)
end

delete '/room/:id' do
  room = Room.find(params[:id])
  connections = Room::Connection.where(destination_id: room.id)

  connections.destroy_all
  room.destroy

  {success: true}.to_json
end
