---
marp: true
theme: default
class: lead
paginate: true
backgroundColor: #1a1a2e
color: #e6e6ea
style: |
  h1 { color: #e94560; font-size: 3.5em; }
  h2 { color: #0f3460; font-size: 2.5em; }
  h3 { color: #e94560; }
  strong { color: #e94560; }
  .columns { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 2rem; align-items: center; }
  .center { text-align: center; }
  .mermaid { text-align: center; background-color: #e6e6ea; padding: 1rem; border-radius: 8px; margin: 0 auto; display: block; }
---

# 💥 Chaos Engineering

*Presentado por: Agustín García Smith*

---

## El problema moderno...

Las arquitecturas modernas (microservicios, nube) son **inmensamente complejas**.

* **No importa cuánto lo intentes, las cosas van a fallar.**

<!--
Modificamos configuraciones y metemos código a producción muchas veces al día. Todo este dinamismo, junto con complejidad inherente a los sistemas distribuidos, hacen que nuestros entornos sean inherentemente caóticos.
-->

---

## El "Happy Path" vs. El Mundo Real

Probar solo casos de éxito nos da una **falsa seguridad**.

En el mundo real:
* La red sufre picos de latencia extremos.
* Los discos se llenan silenciosamente.
* Servicios de terceros devuelven respuestas basura.
* Despliegues de configuración erróneos.
* Certificados SSL expirados.
* Colas de mensajes (Kafka/RabbitMQ) saturadas.

<!--
El camino feliz donde el usuario hace todo bien y nuestra red es perfecta no existe en el mundo real. La tentación de probar solo el camino feliz nos deja ciegos frente a los problemas del mundo real.
-->

---

## Cambio de Paradigma

Dejamos de centrarnos en:
> *"¿El microservicio cumple su contrato interno al pie de la letra?"*

Adoptamos una **Perspectiva de Sistemas**:
> ***"¿El usuario final puede usar el servicio?"***

El sistema se analiza desde su **frontera**, como un **ente vivo**. Mientras el usuario no note el fallo interno, el sistema es resiliente.

<!--
En sistemas distribuidos grandes es imposible tener una especificación funcional exhaustiva. Entonces, dejamos de tratar a los componentes como piezas aisladas y pasamos a verlos como un organismo en su conjunto.
-->

---

## 🤷‍♂️ ¿Qué es Chaos Engineering?

Es la disciplina de realizar **experimentación controlada y proactiva** sobre sistemas distribuidos para descubrir vulnerabilidades sistémicas antes de que generen fallos catastróficos en producción.

*Ejemplo: Inyectar 500ms de latencia en un microservicio de pago para validar si el sistema degrada con elegancia o si colapsa la aplicación.*

<!--
No es romper por romper. Es un enfoque empírico (basado en la observación). Buscamos descubrir debilidades ANTES que ya estan ahi, pero por x circunstancia aun no se manifestaron.
-->

---

## 🤔 Testing Clásico vs Chaos Engineering

<div class="columns">
<div>

### Testing Clásico
Comprueba cosas que *sabes* que pueden pasar (**Aserciones**).

</div>
<div>

### Chaos Engineering
Descubre cosas que *no sabías* que podían pasar (**Cisnes Negros**).

</div>
</div>

<!--
Esta es la diferencia clave. En el testing tradicional (unit tests, integration), nosotros escribimos qué queremos probar. Es un camino ya conocido.
El caos nos sirve para descubrir las cosas que no sabes que no sabias, cosas que ni nos imaginábamos que la red o la infraestructura podían hacernos al interactuar.
-->

---

## 📐 El "Triángulo de Oro"

No podemos hablar de Caos sin entender su relación con otras dos disciplinas clave:

1. 🏆 **Reliability (Confiabilidad):** El objetivo final. La garantía de que el sistema estará disponible cuando el usuario lo necesite.
2. 👁️ **Observability (Observabilidad):** El requisito previo. La capacidad de entender el estado interno del sistema analizando sus métricas, logs y trazas.
3. 🛠️ **Chaos Engineering:** El método. Usamos el caos proactivo, apoyado en la observabilidad, para validar y maximizar la confiabilidad.

<!--
Estas tres disciplinas van de la mano. La confiabilidad es nuestra meta de negocio. El caos es la herramienta que usamos para llegar ahí, pero sin observabilidad estamos ciegos.
-->

---

## 👁️ Sin Observabilidad, no hay Caos

Hacer Chaos Engineering sin buena observabilidad es **suicida**.

* ¿Cómo definís el "estado estable" si no tenés métricas de negocio?
* Cuando inyectás un fallo, ¿cómo sabés si el sistema está degradando con elegancia o si está colapsando?
* ¿Cómo sabés cuándo abortar el experimento para contener el *Blast Radius*?

> *"La observabilidad es la lente; el caos es la prueba de esfuerzo."*

<!--
Este es un punto súper importante. Si en el trabajo les proponen empezar a apagar servidores pero no tienen buenos dashboards, alertas ni traces distribuidos... ¡Frenen todo! El paso 0 del Chaos Engineering es tener observabilidad total.
-->

---

## ⚙️ El Flow del Caos

![Flow del Caos](https://kroki.io/mermaid/svg/eNp1z8FKw0AQBuB7n2JAwl5MaNpYsIdCkqYoeBLxEnqYNGO6dLsbJitY0zyVj-CLmW4q7UF3Dgvz_f_Cel4rtbRzaIXd0p7EHESBDYlbGBavyBILRU0vLYia5R75kBpl-JS9Gb9No9n4FD_TC33YC9OsH7zixHBJfBW4j-6GvpKa_irafx4scLOr2Lzr0kGIIU5IQNd1njeqGOstPD2PoD9xHgaQNRZL467-O2vw_QUk-SSAB1l_f1lqZLN26cRRmk8DeNQH2lhkSNGcNXW6zKMAYo1KfiIPsAQ_8BfHFSqFR8jymJkq9auZU4h_ADudbK0=)

<!--
1. Definimos cómo se ve lo "normal".
2. Hacemos una predicción informada.
3. Inyectamos variables del mundo real.
4. Comparamos el grupo de control contra el experimental para refutar nuestra hipótesis.
5. Arreglamos y repetimos.
-->

---

## 🛒 Flow del Caos Aplicado: E-Commerce

**Escenario Base:**
Tenemos un E-Commerce donde los usuarios navegan y compran. 

Existe un Microservicio de **"Sugerencias de Productos"** (Ej: "Otros usuarios también compraron..."). 
Este servicio *agrega valor*, pero **no es vital** para finalizar una compra.

---

## 1️⃣ Paso 1: Definir el Estado Estable

Para nuestro E-Commerce, lo "normal" se define mediante una **métrica de negocio vital**.

* **Estado Estable**: La plataforma procesa consistentemente **> 50 Compras por Segundo (CPS)** durante las horas pico.
* *Nota: No nos importa si el CPU está al 40% o al 80%, nos importa el CPS.*

<!--
Este es el baseline. Si en algún momento de nuestro experimento el CPS cae, significa que el negocio está perdiendo dinero y el experimento descubrió un fallo crítico que afecta al usuario.
-->

---

## 📊 Steady State y Métricas de Negocio

El "Estado Estable" debe medirse con **métricas de negocio**, no métricas técnicas.

* **Métrica de Negocio (SÍ):** *Starts Per Second* (SPS) de Netflix, Compras por segundo.
* **Métrica Técnica (NO):** Consumo de CPU, RAM, latencia de base de datos.

---

## ¿Por qué Métricas de Negocio?

Las métricas técnicas **no reflejan la experiencia del usuario**. 

* Si el CPU llega al 99%, pero el sistema auto-escala y el cliente no lo nota... **El sistema es resiliente**.
* Si el CPU está perfecto al 10%, pero la pasarela de pagos rechaza el 50% de las tarjetas... **El sistema está fallando**.

Usamos las métricas técnicas para investigar *por qué* falló el experimento, pero medimos el éxito con el impacto en el negocio.

---

## 2️⃣ Paso 2: La Hipótesis

Creamos una predicción informada de cómo debería reaccionar el sistema ante el caos:

> *"Si el servicio de **Sugerencias se cae**, la pasarela de pago no debería verse afectada.*
> *El usuario verá una lista vacía de sugerencias, pero el **CPS se mantendrá constante en 50**."*

<!--
Nuestra hipótesis asume que los microservicios están bien desacoplados y que existe un "Graceful degradation". Es decir, si no hay sugerencias, la página simplemente no las muestra y permite seguir con el checkout de forma ininterrumpida.
-->

---

## Eventos Reales y Graceful Degradation

Degradar con **"elegancia"** (*Graceful Degradation*) significa que si una parte no-crítica del sistema falla, el usuario final sigue recibiendo valor.

* **Falla Recomendaciones:** Ocultar el panel de recomendaciones en lugar de bloquear la compra.
* **Falla el Historial de Netflix:** Reanudar la película desde el principio en lugar de tirar un Error 500.
* **Falla pasarela de pago A:** Derivar automáticamente al proveedor B.

<!--
Nuestras variables de caos simulan eventos reales. Y cuando inyectamos esos fallos, queremos comprobar la resiliencia de la arquitectura. Fallos en servicios no críticos NUNCA deberían tener un impacto fatal en la experiencia del usuario.
-->

---

## 3️⃣ Paso 3: Inyectar Caos

En nuestro entorno de producción (con un *Blast Radius* acotado):
* Usamos una herramienta de Chaos Engineering para **bloquear el 100% del tráfico de red** hacia el microservicio de Sugerencias durante 5 minutos.

<!--
Simulamos que el cable de red del servidor de Sugerencias se rompió o que el contenedor colapsó. Para acotar el impacto (Blast Radius), podríamos hacer este experimento solo para el 5% del tráfico real.
-->

---

## ⚠️ Ejecutar en Producción

¿Por qué no usar solo el entorno de *Staging*?
* Escala diferente.
* Tráfico real impredecible.
* Configuraciones de DNS/Red diferentes.
* Es el único lugar donde la experiencia del usuario es real.
* Para probar patrones de resiliencia como "Circuit Breakers" y "Fallbacks" se necesitan usuarios reales.

---

## 💥 Blast Radius

¿Cómo ejecutamos en producción sin que nos despidan? Conteniendo el **impacto**.

---

## 💥 Blast Radius

<div class="center">

![Blast Radius](https://kroki.io/mermaid/svg/eNqNkt9qwjAUxu99ioCU3jiw9Q8su7PudsiQ3YgXp82pDcakS1KmiA819gi-2NqmardZWAptk9_3fck5xPOOXHJLydG3Ge7Qp8SPwaA_IG7hDTSHWKApyZH4ueY70IdICaUrbX-YjsbTYSVv0BL39oZxWj7QwjOlGeqW4HE8cX7BJd4z2o7AGJLtRqtCshoEEECIPjmdTp7X22jIM7Kc90g5TBG7ea4VI6tF-S6ShJ-_5LrmPzSxAGPJalZ_XoHxwpAFvhd4_lQ3eTWiYBUpaVEiU5o873MsS0RpQawppUkGylz1KNn1Pwrbvheld6XjRkdd9JKRlEczc0xJvQVJuRC06eMgqRpF-2maPrnS7UGgq7vWSSVxYKxWW6RNL5vpwwdnNqNhvr-EONyKca25k-P2_pPTLDAwGWgNB0omZNKZHoVNKe5K_T5lp230f9s3HaHrzg==)

</div>

<!--
El Blast Radius es clave. Experimentar en producción es peligroso, por hay que minimizar el impacto. Empiezas probando afectando a 1 solo contenedor de 100, o solo al 1% del tráfico real. Si las métricas de negocio detectan un fallo catastrófico que no esperabas, el experimento se aborta automáticamente antes de afectar a los demás usuarios.
-->

---

## 4️⃣ Paso 4: Analizar Resultados

Miramos nuestros dashboards monitorizando el CPS:

* 🚨 **Resultado**: El CPS **cayó de 50 a 10**. 
* **Causa**: La página de Checkout se quedaba colgada durante 30 segundos intentando conectarse al servicio de Sugerencias, bloqueando la compra.
* **¡La hipótesis fue refutada!**

<!--
A diferencia del testing tradicional que nos hubiera dicho que el servicio de Sugerencias funcionaba bien de forma aislada, el caos nos demostró que una falla de red en un servicio secundario arrastro y rompio toda la pasarela de pagos.
-->

---

## 5️⃣ Paso 5: Arreglar (y repetir)

Usamos lo aprendido para hacer el sistema resiliente:

* **Fix**: Implementamos un patrón *Circuit Breaker* y un **timeout agresivo de 200ms** en la llamada a Sugerencias.
* Si no responde en 200ms, el frontend aborta la petición y continúa.

*El martes siguiente, se repite el experimento y esta vez... **el CPS se mantiene estable**.* ✅

<!--
Así se cierra el ciclo. Arreglamos la debilidad arquitectónica y automatizamos este experimento para que corra cada semana de forma automática. Si algún dev introduce código que vuelve a acoplar mal estos servicios, nos enteraremos antes de que afecte a las ventas reales.
-->

---

## 🤖 Automatizar Experimentos

El software cambia todos los días: nuevos commits, configuraciones, cuellos de botella.

* La resiliencia comprobada ayer puede romperse con el código de hoy.
* **Solución:** Automatizar los experimentos para que corran continuamente integrados en el pipeline de CI/CD.

---

# 🛠️ Herramientas Populares

---

## 🐵 Chaos Monkey (Netflix)

* El pionero, parte de la mítica **Simian Army** de Netflix.
* **Mecanismo:** Finaliza aleatoriamente instancias de máquinas virtuales (ej. EC2 en AWS) en producción.
* **Enfoque técnico:** Fuerza a la arquitectura a estar diseñada para la recuperación automática (auto-scaling, stateless services) desde el día 1.
* 🔗 [github.com/Netflix/chaosmonkey](https://github.com/Netflix/chaosmonkey)

<!--
Netflix lo corría durante horas laborales. La filosofía era: si sabemos que los servidores de AWS se pueden apagar solos en cualquier momento, mejor apaguémoslos nosotros el martes a las 10 AM, cuando todo el equipo está en la oficina y puede responder.
-->

---

## 👾 Gremlin

* Plataforma "Chaos as a Service" (SaaS) orientada a Enterprise.
* **Mecanismo:** Arquitectura basada en agentes (*Gremlin Daemon*) con orquestación centralizada y control de RBAC.
* **Enfoque técnico:** Permite inyección de fallos a nivel aplicación (ALFI) y de recursos (agotamiento de CPU/RAM, manipulación de I/O, latencia de red).
* 🔗 [gremlin.com](https://www.gremlin.com/)

<!--
Esta es la opción paga y súper profesional orientada a la seguridad corporativa. Si lanzas un ataque que inyecta latencia y ves que tus métricas de negocio se desploman a cero, apretás el botón de "Halt" (Pánico) y el agente revierte todo a la normalidad en milisegundos.
-->

---

## ☸️ Chaos Mesh & Litmus

* Proyectos incubados por la **CNCF** (Cloud Native Computing Foundation).
* **Mecanismo:** Nativos de Kubernetes. Operan mediante **CRDs** (Custom Resource Definitions) y el patrón Operator.
* **Enfoque técnico:** Inyectan fallos declarativos vía YAML (Ej: `PodChaos`, `NetworkChaos`). Se integran perfectamente en pipelines de GitOps (ArgoCD/Flux).
* 🔗 [chaos-mesh.org](https://chaos-mesh.org/) | 🔗 [litmuschaos.io](https://litmuschaos.io/)

<!--
Si la empresa usa Kubernetes, usarán alguna de estas dos. La gran ventaja es que todo es declarativo como código. Escribes un YAML diciendo "quiero un 5% de packet loss en los pods con el label db=postgres" y el operador de K8s orquesta todo el ataque usando sidecars o daemonsets.
-->

---

## 🐗 Pumba

* Herramienta minimalista enfocada exclusivamente en **Docker**.
* **Mecanismo:** Interactúa directamente con la API del demonio de Docker.
* **Enfoque técnico:** Usa las utilidades nativas del kernel de Linux (`tc` y `netem`) para emular pérdida de paquetes, retrasos y reordenamiento a nivel de red puente (bridge).
* 🔗 [github.com/alexei-led/pumba](https://github.com/alexei-led/pumba)

<!--
Esta es la herramienta que vamos a usar en la demo. Es fantástica para pruebas locales o PoCs rápidas porque no requiere instalar toda la complejidad de Kubernetes. Simplemente lanzas un contenedor Pumba montando el socket de Docker y este puede afectar a los demás contenedores hermanos.
-->

---

## 💻 Demo Time!

Arquitectura del E-Commerce (PoC):

* 🖥️ **Frontend SRE:** Dashboard reactivo monitoreando CPS, Latencia y CPU en tiempo real.
* 🛡️ **Gateway API (FastAPI):** Servicio principal con Circuit Breaker y Caché en memoria.
* 📦 **Sugerencias (FastAPI):** Microservicio secundario (aislado a `0.5` CPUs).
* 🗄️ **Redis:** Componente crítico de base de datos.
* 🐗 **Pumba:** Inyector de Caos progresivo a nivel red y kernel.

---

## 🛡️ Circuit Breaker & Fail-Fast

¿Por qué esperar a chocar contra la pared repetidamente?

* Si el servicio de sugerencias se cae o tiene latencia extrema, los **Timeouts agotan recursos** (hilos, sockets, memoria).
* **Solución:** Al detectar $N$ fallos, el Gateway hace "Cortocircuito" (Estado ABIERTO).
* **Fail-Fast:** Rechaza llamadas inmediatamente ($0$ ms de latencia) hasta que detecta que el servicio se recuperó (Estado SEMI-ABIERTO).
* *Protegemos el throughput global aislando la falla.*

---

## 🗃️ Caché de Respaldo

¿Qué devolvemos cuando el Circuit Breaker corta la conexión?

* No mostrar nada degrada la experiencia del usuario.
* **Solución:** El Gateway guarda en memoria la **última respuesta válida**.
* Ante un fallo o circuito abierto, se entregan estos "datos oxidados" de forma transparente.
* *Graceful Degradation llevado al extremo: el usuario ni se entera del fallo.*

---

## 🧱 Bulkhead (Aislamiento)

"Si se hunde un compartimento del barco, que no se hunda todo el barco."

* ¿Qué pasa si un servicio tiene un *memory leak* o un bucle infinito? Puede colgar toda la máquina host (*Noisy Neighbor*).
* **Solución:** Restricciones duras en los cgroups de Linux.
* Nuestro contenedor de Sugerencias está limitado a `0.5` núcleos (`deploy.resources.limits`). 
* *Aunque intente usar 100% de CPU, Docker lo estrangula salvando al Gateway.*

---

## 💻 Hipótesis de las Demos

**Demo 1: Tormenta de Red (Latencia Progresiva)**
* Inyectaremos 50ms, luego 150ms y finalmente 400ms de latencia al servicio secundario.
* *Predicción:* El Gateway cortará por Timeout, el Circuit Breaker se abrirá y entrará el Caché. El CPS se mantendrá intacto.

---

## 💻 Hipótesis de las Demos

**Demo 2: El Vecino Ruidoso (Asfixia de CPU)**
* Saturares progresivamente la cuota de CPU del contenedor (50%, 80%, 100%).
* *Predicción:* La latencia será nula al 80%, pero explotará por **Runqueue Starvation** al 100%, obligando al Gateway a defenderse.

---

## 🚀 Takeaways

- **La resiliencia se diseña**: Circuit Breakers, Bulkheads y Fallbacks salvan negocios.
- **El Caos como Validación**: No sabés si tu Circuit Breaker funciona hasta que le inyectás latencia en el mundo real.

---

## 📚 Fuentes y Lecturas Recomendadas

* 🌐 **Principles of Chaos Engineering:** (🔗 [principlesofchaos.org](https://principlesofchaos.org/))
* 📘 **Release It! (Michael Nygard):** La biblia sobre patrones de resiliencia (Circuit Breaker, Bulkhead).
* 📘 **Chaos Engineering (O'Reilly):** Casey Rosenthal y Nora Jones.

---

# ¡Gracias! 💥

¿Preguntas?
