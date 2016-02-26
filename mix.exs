defmodule NodePort.Mixfile do
  use Mix.Project

  def project do
    [app: :node_port,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :poolboy]]
  end

  defp deps do
    [{:poolboy, "~> 1.5"}]
  end
end
