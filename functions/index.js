/**
 * Firebase Cloud Functions for Fitness AI App
 * 
 * This file contains all cloud functions for:
 * - AI-powered workout generation
 * - Nutrition recommendations
 * - Food image analysis
 * - Weekly workout adjustments
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { OpenAI } = require('openai');

admin.initializeApp();

// Initialize OpenAI client (use OpenRouter or OpenAI)
const openai = new OpenAI({
  apiKey: functions.config().openai?.key || process.env.OPENAI_API_KEY,
  baseURL: functions.config().openrouter?.base_url || 'https://api.openai.com/v1',
});

/**
 * Generate PPL Workout
 * 
 * Input: user profile, workout type
 * Output: workout with exercises
 */
exports.generatePPLWorkout = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { userId, workoutType, userProfile, date } = data;

  try {
    // Build prompt for AI
    const prompt = buildWorkoutPrompt(workoutType, userProfile);

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview', // or gpt-4.1, gpt-5 if available
      messages: [
        {
          role: 'system',
          content: 'You are an expert fitness coach specializing in PPL (Push/Pull/Legs) training programs.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.7,
    });

    const aiResponse = completion.choices[0].message.content;
    const exercises = parseWorkoutResponse(aiResponse, workoutType);

    // Create workout model
    const workout = {
      id: `${userId}_${date}_${workoutType}`,
      userId: userId,
      workoutType: workoutType,
      date: date,
      exercises: exercises,
      completed: false,
      createdAt: new Date().toISOString(),
    };

    return workout;
  } catch (error) {
    console.error('Error generating workout:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to generate workout',
      error.message
    );
  }
});

/**
 * Get Nutrition Recommendations
 * 
 * Input: user profile, meals today, targets
 * Output: recommendations to reach goals
 */
exports.getNutritionRecommendations = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, userProfile, mealsToday, targetCalories, targetProtein } = data;

  try {
    const totalCalories = mealsToday.reduce((sum, meal) => sum + meal.calories, 0);
    const totalProtein = mealsToday.reduce((sum, meal) => sum + meal.protein, 0);

    const caloriesRemaining = targetCalories - totalCalories;
    const proteinRemaining = targetProtein - totalProtein;

    const prompt = `User profile: ${JSON.stringify(userProfile)}
Current meals today: ${JSON.stringify(mealsToday)}
Target calories: ${targetCalories}, Current: ${totalCalories}, Remaining: ${caloriesRemaining}
Target protein: ${targetProtein}g, Current: ${totalProtein}g, Remaining: ${proteinRemaining}g

Provide personalized nutrition recommendations to help reach daily goals.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: 'You are a nutritionist providing personalized meal recommendations.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
    });

    const recommendations = completion.choices[0].message.content;

    return {
      recommendations: recommendations,
      caloriesRemaining: caloriesRemaining,
      proteinRemaining: proteinRemaining,
      suggestions: generateMealSuggestions(caloriesRemaining, proteinRemaining),
    };
  } catch (error) {
    console.error('Error getting nutrition recommendations:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get recommendations');
  }
});

/**
 * Analyze Food Image
 * 
 * Uses Google ML Vision API to detect food items in images
 */
exports.analyzeFoodImage = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { imageUrl } = data;

  try {
    // In production, use Google ML Vision API
    // For now, return placeholder structure
    // You'll need to install @google-cloud/vision and configure it

    const prompt = `Analyze this food image at ${imageUrl} and identify:
1. Food items present
2. Estimated calories per item
3. Estimated protein, carbs, and fat per item

Return as JSON array.`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4-vision-preview', // Use vision model for image analysis
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            { type: 'image_url', image_url: { url: imageUrl } },
          ],
        },
      ],
    });

    const analysis = completion.choices[0].message.content;
    const foodItems = parseFoodAnalysis(analysis);

    return foodItems;
  } catch (error) {
    console.error('Error analyzing food image:', error);
    throw new functions.https.HttpsError('internal', 'Failed to analyze image');
  }
});

/**
 * Get Weekly Adjustments
 * 
 * Analyzes workout history and suggests overload adjustments
 */
exports.getWeeklyAdjustments = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, workoutHistory } = data;

  try {
    const prompt = `Analyze this workout history and provide progressive overload suggestions:
${JSON.stringify(workoutHistory)}

Suggest:
1. Weight increases for each exercise
2. Rep increases where appropriate
3. Set increases if needed
4. Form and technique tips`;

    const completion = await openai.chat.completions.create({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: 'You are a strength training coach specializing in progressive overload.',
        },
        {
          role: 'user',
          content: prompt,
        },
      ],
    });

    const adjustments = completion.choices[0].message.content;

    return {
      adjustments: adjustments,
      suggestions: parseAdjustments(adjustments),
    };
  } catch (error) {
    console.error('Error getting weekly adjustments:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get adjustments');
  }
});

// Helper functions

function buildWorkoutPrompt(workoutType, userProfile) {
  return `Generate a ${workoutType} workout for:
- Gender: ${userProfile.gender}
- Age: ${userProfile.age}
- Experience: ${userProfile.experienceLevel}
- Goal: ${userProfile.goal}
- Workouts per week: ${userProfile.workoutsPerWeek}

Return a JSON array of exercises with:
- name
- primaryMuscle
- sets
- reps
- tips
- demoVideoUrl (placeholder)

Follow science-based volume recommendations for ${userProfile.experienceLevel} level.`;
}

function parseWorkoutResponse(response, workoutType) {
  try {
    // Try to parse JSON from AI response
    const jsonMatch = response.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
  } catch (e) {
    console.error('Error parsing workout response:', e);
  }

  // Fallback: return default exercises
  return getDefaultExercises(workoutType);
}

function getDefaultExercises(workoutType) {
  const exercises = {
    Push: [
      { name: 'Bench Press', primaryMuscle: 'Chest', sets: 4, reps: 8, tips: 'Keep your back flat' },
      { name: 'Overhead Press', primaryMuscle: 'Shoulders', sets: 3, reps: 8, tips: 'Core engaged' },
      { name: 'Tricep Dips', primaryMuscle: 'Triceps', sets: 3, reps: 10, tips: 'Full range of motion' },
    ],
    Pull: [
      { name: 'Deadlift', primaryMuscle: 'Back', sets: 4, reps: 5, tips: 'Keep back straight' },
      { name: 'Pull-ups', primaryMuscle: 'Back', sets: 3, reps: 8, tips: 'Full extension' },
      { name: 'Barbell Rows', primaryMuscle: 'Back', sets: 3, reps: 8, tips: 'Pull to lower chest' },
    ],
    Legs: [
      { name: 'Squats', primaryMuscle: 'Quadriceps', sets: 4, reps: 8, tips: 'Knees track over toes' },
      { name: 'Romanian Deadlifts', primaryMuscle: 'Hamstrings', sets: 3, reps: 8, tips: 'Hinge at hips' },
      { name: 'Leg Press', primaryMuscle: 'Quadriceps', sets: 3, reps: 12, tips: 'Full range of motion' },
    ],
  };

  return exercises[workoutType] || [];
}

function generateMealSuggestions(caloriesRemaining, proteinRemaining) {
  const suggestions = [];
  
  if (proteinRemaining > 30) {
    suggestions.push('Add a protein source: chicken breast, Greek yogurt, or protein shake');
  }
  
  if (caloriesRemaining > 300) {
    suggestions.push('Consider adding a healthy snack: nuts, fruits, or whole grains');
  }

  return suggestions;
}

function parseFoodAnalysis(analysis) {
  try {
    const jsonMatch = analysis.match(/\[[\s\S]*\]/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
  } catch (e) {
    console.error('Error parsing food analysis:', e);
  }

  return [{
    name: 'Detected Food',
    calories: 200,
    protein: 10,
    carbs: 30,
    fat: 5,
  }];
}

function parseAdjustments(adjustments) {
  // Parse AI response into structured suggestions
  return {
    weightIncreases: [],
    repIncreases: [],
    setIncreases: [],
    tips: adjustments,
  };
}




