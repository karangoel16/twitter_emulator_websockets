defmodule TwitterNewWeb.PageController do
  use TwitterNewWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
