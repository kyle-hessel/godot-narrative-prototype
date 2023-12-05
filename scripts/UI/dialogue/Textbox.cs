using Godot;
using System;
using System.Text;

[GlobalClass]
public partial class Textbox : CanvasLayer
{
	public MarginContainer TextboxMargin;
	public Label TextboxLabel;
	public Timer LetterDisplayTimer;

	public StringBuilder Dialogue = new StringBuilder("", 100);
	private int _letterIndex = 0;
	private const int MaxWidth = 256;
	
	[Export]
	private float _letterTime = 0.03f;
	[Export]
	private float _spaceTime = 0.06f;
	[Export]
	private float _punctuationTime = 0.2f;

	[Signal]
	public delegate void DisplayCompleteEventHandler();
	
	public override void _Ready()
	{
		TextboxMargin = GetNode<MarginContainer>("TextboxMargin");
		TextboxLabel = GetNode<Label>("TextboxMargin/TextboxPanel/TextboxLabel");
		LetterDisplayTimer = GetNode<Timer>("LetterDisplayTimer");
	}
	
	public override void _Process(double delta)
	{
	}

	public void _DisplayText(string textToDisplay)
	{
		Dialogue.Append(textToDisplay);
		TextboxLabel.Text = Dialogue.ToString();

		//await ToSignal(TextboxMargin, "resized");
		//var textboxMarginCustomMinimumSize = TextboxMargin.CustomMinimumSize;
		//textboxMarginCustomMinimumSize.X = Mathf.Min(TextboxMargin.Size.X, MaxWidth);
	}
}
