using Godot;
using System;

[GlobalClass]
public partial class Textbox : CanvasLayer
{
	public Label TextboxLabel;
	public Timer LetterDisplayTimer;
	public override void _Ready()
	{
		TextboxLabel = GetNode<Label>("TextboxMargin/TextboxPanel/TextboxLabel");
		LetterDisplayTimer = GetNode<Timer>("LetterDisplayTimer");
	}
	
	public override void _Process(double delta)
	{
	}
}
