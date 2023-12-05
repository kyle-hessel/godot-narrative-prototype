using Godot;
using System;
using System.Text;

[GlobalClass]
public partial class Textbox : CanvasLayer
{
	private MarginContainer _textboxMargin;
	private Label _textboxLabel;
	private Timer _letterDisplayTimer;

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
		_textboxMargin = GetNode<MarginContainer>("TextboxMargin");
		_textboxLabel = GetNode<Label>("TextboxMargin/TextboxPanel/TextboxLabel");
		_letterDisplayTimer = GetNode<Timer>("LetterDisplayTimer");
		_letterDisplayTimer.Timeout += OnLetterDisplayTimerTimeout; // C# magic?
	}
	
	public override void _Process(double delta)
	{
	}

	public void _DisplayText(string textToDisplay)
	{
		Dialogue.Append(textToDisplay);
		var dialogueString = Dialogue.ToString();
		_textboxLabel.Text = dialogueString;

		// If the next section below is used for resizable support, comment out these lines as they already exist there, just in a different order.
		_textboxLabel.AutowrapMode = TextServer.AutowrapMode.Word;
		_textboxLabel.Text = "";
		_DisplayLetter(dialogueString);
		
		// Commented out lines are for resizable dialogue box support. I may just keep it static.
		/*
		await ToSignal(TextboxMargin, "resized");
		
		var textboxMarginCustomMinimumSize = TextboxMargin.CustomMinimumSize;
		textboxMarginCustomMinimumSize.X = Mathf.Min(TextboxMargin.Size.X, MaxWidth);
		
		TextboxLabel.AutowrapMode = TextServer.AutowrapMode.Word;
		
		await ToSignal(TextboxMargin, "resized");
		await ToSignal(TextboxMargin, "resized");
		
		textboxMarginCustomMinimumSize.Y = TextboxMargin.Size.Y;
		var textboxMarginGlobalPosition = TextboxMargin.GlobalPosition;
		textboxMarginGlobalPosition.X -= TextboxMargin.Size.X * 0.5f;
		textboxMarginGlobalPosition.Y -= TextboxMargin.Size.Y + 24.0f;
		
		TextboxLabel.Text = "";
		_DisplayLetter(dialogueString);
		*/
	}
	
	public void _DisplayLetter(string dialogueText)
	{
		var dialogueCharString = dialogueText[_letterIndex].ToString();
		_textboxLabel.Text = dialogueCharString;
		_letterIndex++;
		
		if (_letterIndex >= dialogueText.Length)
		{
			EmitSignal(SignalName.DisplayComplete);
			return;
		}

		switch (dialogueCharString)
		{
			case "!":
			case ".":
			case ",":
			case "?":
				_letterDisplayTimer.Start(_punctuationTime);
				break;
			case " ":
				_letterDisplayTimer.Start(_spaceTime);
				break;
			default:
				_letterDisplayTimer.Start(_letterTime);
				break;
		}
	}

	private void OnLetterDisplayTimerTimeout()
	{
		_DisplayLetter(Dialogue.ToString());
	}
}
