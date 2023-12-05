using Godot;
using System;

[GlobalClass]
public partial class DialogueManager : Node
{
	public PackedScene Textbox = GD.Load<PackedScene>("res://scenes/UI/dialogue/textbox.tscn");
	public Textbox TextboxInstance;
	
	private string[] _dialogueLines = Array.Empty<string>();
	private int _currentLineIndex = 0;
	private bool _isDialogueActive = false;
	private bool _canAdvanceLine = false;

	public override void _Ready()
	{
		string[] test =
		{
			"Ayo, man, what's poppin?",
			"Ya like jazz?",
			"What's the deal with game engines anyway? *laugh track*"
		};
		
		StartDialogue(test);
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		base._UnhandledInput(@event);

		if (@event.IsActionPressed("gui_select") && _isDialogueActive && _canAdvanceLine)
		{
			TextboxInstance.QueueFree();
			_currentLineIndex++;

			if (_currentLineIndex >= _dialogueLines.Length)
			{
				_isDialogueActive = false;
				_currentLineIndex = 0;
				return;
			}
			
			ShowTextbox();
		}
	}

	public void StartDialogue(string[] lines)
	{
		if (_isDialogueActive)
			return;

		_dialogueLines = lines;
		ShowTextbox();

		_isDialogueActive = true;
	}

	public async void ShowTextbox()
	{
		TextboxInstance = Textbox.Instantiate<Textbox>();
		TextboxInstance.DisplayComplete += OnTextboxFinishedDisplaying;
		GetParent().GetNode<Control>("UIManager").CallDeferred("add_child", TextboxInstance); // Easiest way to do this as the GameManager singleton is harder to fetch here.
		await ToSignal(TextboxInstance, "ready");
		TextboxInstance._DisplayText(_dialogueLines[_currentLineIndex]);
		_canAdvanceLine = false;
	}

	private void OnTextboxFinishedDisplaying()
	{
		_canAdvanceLine = true;
	}
}
