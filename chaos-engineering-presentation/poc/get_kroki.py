import base64, zlib

def get_kroki_url(diagram_type, text):
    data = text.encode('utf-8')
    compressed = zlib.compress(data, 9)
    encoded = base64.urlsafe_b64encode(compressed).decode('utf-8')
    return f"https://kroki.io/{diagram_type}/svg/{encoded}"

theme = "%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#0f3460', 'primaryTextColor': '#e6e6ea', 'primaryBorderColor': '#e94560', 'lineColor': '#e6e6ea', 'textColor': '#e6e6ea', 'background': '#1a1a2e' }}}%%\n"

blast = theme + """graph TD
    subgraph prod [Producción]
        subgraph blast [Blast Radius Pequeño]
            C1[Contenedor Experimental]:::chaos
        end
        C2[Contenedor Normal]
        C3[Contenedor Normal]
    end
    classDef chaos fill:#e94560,color:#fff;
    style prod fill:none,stroke:#e6e6ea,stroke-width:2px,color:#e6e6ea
    style blast fill:none,stroke:#e94560,stroke-width:2px,stroke-dasharray: 5 5,color:#e6e6ea
    style C2 fill:#0f3460,stroke:#e6e6ea,color:#e6e6ea
    style C3 fill:#0f3460,stroke:#e6e6ea,color:#e6e6ea"""

print("\nBLAST URL:\n", get_kroki_url("mermaid", blast))
