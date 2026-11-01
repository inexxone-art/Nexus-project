extends RefCounted
class_name NexusLore
## Branching campaign outlines and interactive final decisions on six prototype levels.
const STORY = {
    "terra": {
        "faction":"Bergrettung / NEXUS Forschung",
        "arrival":"Eine Lawine legt ein Raumschiffwrack in den Alpen frei. Sein Sender kennt deinen Namen.",
        "scan":"Analysiere die geborgene Signatur beim Eisradar.",
        "conflict":"Eine private Sicherheitsfirma blockiert den Forschungskonvoi.",
        "recovery":"Berge die Koordinaten fuer den Sprung nach Sahra IX.",
        "choice_a":"Schuetze die Wissenschaftler", "choice_b":"Uebergib die Daten an die Bevoelkerung",
        "secret":"Das Signal wurde gesendet, lange bevor die erste Kolonie existierte."},
    "sahra": {
        "faction":"Karawanenbund / Wrackpluenderer",
        "arrival":"Ein gigantischer Wuestensturm legt eine Stadt aus schwarzen Schiffsrippen frei.",
        "scan":"Entschluessle den Turm aus Sternenglas.",
        "conflict":"Die Pluenderer wollen den Archivschaechten die Energie abdrehen.",
        "recovery":"Sichere das zweite Fragment unter dem Sandmeer.",
        "choice_a":"Rette die Karawane", "choice_b":"Sichere das Archiv zuerst",
        "secret":"Das Archiv zeigt ein Bild des Eismonds Nivora vor seiner Zerstoerung."},
    "nivora": {
        "faction":"Eisstation Aurora / Autonome Sicherheit",
        "arrival":"Unter dem Eis bewegt sich ein stillgelegter Reaktor wieder.",
        "scan":"Lokalisiere den Ursprung des verschollenen Funkspruchs.",
        "conflict":"Die Sicherheitsdrohnen halten jeden Eindringling fuer kontaminiert.",
        "recovery":"Verbinde den alten Sender mit dem Forschungssatelliten.",
        "choice_a":"Evakuiere die Station", "choice_b":"Stabilisiere zuerst den Reaktor",
        "secret":"Die Station entdeckte biologischen Code, der zu Vesper fuehrt."},
    "vesper": {
        "faction":"Dschungelkolonie / Symbiosekonsortium",
        "arrival":"Ein lebender Wald verarbeitet Radiosignale wie Erinnerungen.",
        "scan":"Untersuche den ersten bioelektrischen Knoten.",
        "conflict":"Ein Konzern versucht die biologische Intelligenz zu kontrollieren.",
        "recovery":"Extrahiere die vierte Signatur ohne den Wald zu zerstoeren.",
        "choice_a":"Beschuetze die Symbiose", "choice_b":"Nutze das Wissen fuer die Kolonie",
        "secret":"Die Wurzeln erinnern sich an den Planeten Umbra."},
    "ignis": {
        "faction":"Arbeiterallianz / Energiekonsortium",
        "arrival":"Auf Ignis Prime reisst eine Sabotage die Stadtversorgung auseinander.",
        "scan":"Finde den Fehler in den Lavakanal-Sensoren.",
        "conflict":"Konzerntruppen besetzen das letzte funktionsfaehige Kraftwerk.",
        "recovery":"Berge den Kernschluessel und leite die Energie um.",
        "choice_a":"Rette die Arbeiterquartiere", "choice_b":"Sichere den interplanetaren Energiebedarf",
        "secret":"Jede Katastrophe wurde von demselben NEXUS-Puls ausgeloest."},
    "umbra": {
        "faction":"NEXUS-Ursprung / Letzte Expedition",
        "arrival":"Zwei Monde schweben ueber Ruinen, die aus noch ungeborener Zeit stammen.",
        "scan":"Aktiviere den ersten Ursprungspfeiler.",
        "conflict":"Die Verteidiger reagieren auf Erinnerungen statt auf Befehle.",
        "recovery":"Berge das sechste Fragment und betrete das NEXUS-Gedaechtnis.",
        "choice_a":"Verbinde alle Welten", "choice_b":"Zerstoere die NEXUS-Kontrolle",
        "secret":"Deine Rettung im Gebirge war der Anfang eines planetaren Experiments."},
}
static func info(pid: String) -> Dictionary:
    return STORY.get(pid, STORY["terra"])
