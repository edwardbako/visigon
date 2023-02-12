import { Controller } from "@hotwired/stimulus"
import { EditorState, Compartment } from "@codemirror/state"
import { EditorView, basicSetup } from "codemirror"
import { StreamLanguage } from "@codemirror/language"
import { ruby } from "@codemirror/legacy-modes/mode/ruby"
import { evaluate } from "../services/rubyVM"

// Connects to data-controller="editor"
export default class extends Controller {
  static targets = ["parent", "output"]

  startState = EditorState.create({
    doc: `
class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def coordinates
    [x,y]
  end
end

p = Point.new(4, 5)
p.coordinates
`,
    extensions: [
      basicSetup,
      StreamLanguage.define(ruby)
    ]
  })

  view = new EditorView({
    state: this.startState,
    parent: this.parentTarget,
  })

  connect() {
  }

  run() {
    let program = this.view.state.doc.toString()

    this.outputTarget.innerHTML = evaluate(program)
  }

}
