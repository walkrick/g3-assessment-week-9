require "sinatra"
require "gschool_database_connection"
require "rack-flash"
require "active_record"
require "./lib/to_do_item"
require "./lib/user"

class ToDoApp < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    # @database_connection = GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"])
    # @to_do_items_table = ToDoItemTable.new(GschoolDatabaseConnection::DatabaseConnection.establish(ENV["RACK_ENV"]))

  end

  get "/" do
    if current_user
      user = current_user

      users = User.where("id != #{user.id}")
      todos = ToDoItem.all
      erb :signed_in, locals: {current_user: user, users: users, todos: todos}
    else
      erb :signed_out
    end
  end

  get "/register" do
    erb :register
        # locals: {user: User.new}
  end

  post "/registrations" do
    user = User.new(username: params[:username], password: params[:password])

    if user.save
      flash[:notice] = "Thanks for registering"
      redirect "/"
    else
      erb :register, locals: {user: user}
    end
  end

  post "/sessions" do

    user = authenticate_user

    if user != nil
      session[:user_id] = user.id
    else
      flash[:notice] = "Username/password is invalid"
    end

    redirect "/"
  end

  delete "/sessions" do
    session[:user_id] = nil
    redirect "/"
  end

  post "/todos" do
    ToDoItem.create(body: params[:body])

    flash[:notice] = "ToDo added"

    redirect "/"
  end

  # get "/to_do_items/:id/edit" do
  #   body = @database_connection.sql("SELECT * FROM to_do_items WHERE id = #{params[:id]}").first
  #
  #   erb :"body/edit", locals: {body: body}
  # end
  #
  # patch "/to_do_items/:id/patch" do
  #   body = params[:body]
  #   if message.length <= 140
  #
  #     @to_do_items_table.update(params[:id], params[:message])
  #
  #     flash[:notice] = "Message updated"
  #     redirect "/"
  #
  #   else
  #     flash[:error] = "Message must be less than 140 characters."
  #     redirect "/messages/#{params[:id]}/edit"
  #   end
  # end

  private

  def authenticate_user
    User.authenticate(params[:username], params[:password])
  end

  def current_user
    if session[:user_id]
    User.find(session[:user_id])
    end
    end

end
