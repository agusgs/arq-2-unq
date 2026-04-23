defmodule WeatherFlow.MixProject do
  use Mix.Project

  def project do
    [
      app: :weather_flow,
      version: "0.1.0",
      elixir: "~> 1.19",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      name: "WeatherFlow",
      source_url: "https://github.com/agusgs/arq-2-unq",
      docs: [
        main: "readme",
        extras: [
          "README.md",
          "docs/architecture.md",
          "docs/domain_model.md",
          "docs/database.md",
          "docs/api_guide.md"
        ],
        before_closing_body_tag: fn
          :html ->
            """
            <script src="https://cdn.jsdelivr.net/npm/mermaid@10.2.3/dist/mermaid.min.js"></script>
            <script>
              document.addEventListener("DOMContentLoaded", function () {
                const isDark = document.documentElement.classList.contains("dark") ||
                               (!document.documentElement.classList.contains("light") && window.matchMedia("(prefers-color-scheme: dark)").matches);
                mermaid.initialize({ startOnLoad: false, theme: isDark ? "dark" : "default" });
                let id = 0;
                for (const codeEl of document.querySelectorAll("pre code.mermaid")) {
                  const preEl = codeEl.parentElement;
                  const graphDefinition = codeEl.textContent;
                  const graphEl = document.createElement("div");
                  const graphId = "mermaid-graph-" + id++;
                  mermaid.render(graphId, graphDefinition).then(({svg, bindFunctions}) => {
                    graphEl.innerHTML = svg;
                    bindFunctions?.(graphEl);
                    preEl.insertAdjacentElement("afterend", graphEl);
                    preEl.remove();
                  });
                }
              });
            </script>
            """
          _ -> ""
        end
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WeatherFlow.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8.5"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:mongodb_driver, "~> 1.4"},
      {:open_api_spex, "~> 3.18"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end
end
