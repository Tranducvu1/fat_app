import 'package:fat_app/service/question_service.dart'; // Importing the QuestionService to handle question-related operations
import 'package:flutter/material.dart'; // Flutter package for UI components

class AddQuestionPage extends StatefulWidget {
  final String
      lessonId; // The ID of the lesson to which the question will be added

  const AddQuestionPage({Key? key, required this.lessonId}) : super(key: key);

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>(); // Key for the form validation
  final TextEditingController _questionController =
      TextEditingController(); // Controller for the question text input
  final List<TextEditingController> _answerControllers = List.generate(
    4,
    (index) =>
        TextEditingController(), // List of controllers for answer inputs (4 answers)
  );
  int _selectedCorrectAnswer =
      0; // Track the index of the selected correct answer
  bool _isLoading = false; // Track the loading state while saving the question

  // Instance of the QuestionService for adding the question to Firestore
  final QuestionService _questionService = QuestionService();

  @override
  void dispose() {
    // Dispose the controllers when the widget is destroyed to avoid memory leaks
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Method to save the question when the user submits the form
  Future<void> _saveQuestion() async {
    // Validate the form before saving
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Set loading state to true

    try {
      // Call the QuestionService to add the question to Firestore
      await _questionService.addQuestion(
        widget.lessonId, // Pass the lessonId from the parent widget
        _questionController.text, // Get the question text from the controller
        _answerControllers
            .map((c) => c.text)
            .toList(), // Get the answers from the answer controllers
        _selectedCorrectAnswer, // Pass the selected correct answer index
      );

      // If the question was successfully added, show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question added successfully!'), // Success message
            backgroundColor: Colors.green,
          ),
        );
        _resetForm(); // Reset the form fields after saving
      }
    } catch (e) {
      // If an error occurs, show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: $e'), // Error message with the exception details
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Set loading state back to false once the operation is complete
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Method to reset the form fields after the question is saved
  void _resetForm() {
    _questionController.clear(); // Clear the question field
    for (var controller in _answerControllers) {
      controller.clear(); // Clear each answer field
    }
    setState(
        () => _selectedCorrectAnswer = 0); // Reset the correct answer selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'), // App bar title
        elevation: 0, // Remove shadow under the app bar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Bind the form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card to contain the question and answers input fields
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Rounded corners for the card
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Question text input field
                        TextFormField(
                          controller:
                              _questionController, // Bind the controller to the field
                          decoration: InputDecoration(
                            labelText:
                                'Question', // Label for the question field
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Rounded corners for the input
                            ),
                            filled: true,
                            fillColor:
                                Colors.grey[50], // Light grey background color
                          ),
                          maxLines:
                              3, // Allow multiple lines for the question text
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter a question' // Validation message if the question is empty
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Answer Choices', // Heading for answers
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Dynamically generate answer input fields (4 answers)
                        ...List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Radio button to select the correct answer
                                Radio<int>(
                                  value: index,
                                  groupValue: _selectedCorrectAnswer,
                                  onChanged: (value) {
                                    setState(
                                        () => _selectedCorrectAnswer = value!);
                                  },
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _answerControllers[
                                        index], // Bind each answer controller
                                    decoration: InputDecoration(
                                      labelText:
                                          'Answer ${index + 1}', // Label for each answer field
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            8), // Rounded corners
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[
                                          50], // Light grey background color
                                    ),
                                    validator: (value) => value?.isEmpty == true
                                        ? 'Please enter an answer' // Validation message for empty answer fields
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Button to save the question
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _saveQuestion, // Disable button when loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Rounded corners for the button
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator() // Show loading indicator when saving
                      : const Text(
                          'Save Question', // Button text to save the question
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
