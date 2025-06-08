pub const c = @import("raylib");

// module: rcore
// Window-related functions
pub const initWindow = c.InitWindow; // Initialize window and OpenGL context
pub const closeWindow = c.CloseWindow; // Close window and unload OpenGL context
pub const windowShouldClose = c.WindowShouldClose; // Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
pub const isWindowReady = c.IsWindowReady; // Check if window has been initialized successfully
pub const isWindowFullscreen = c.IsWindowFullscreen; // Check if window is currently fullscreen
pub const isWindowHidden = c.IsWindowHidden; // Check if window is currently hidden
pub const isWindowMinimized = c.IsWindowMinimized; // Check if window is currently minimized
pub const isWindowMaximized = c.IsWindowMaximized; // Check if window is currently maximized
pub const isWindowFocused = c.IsWindowFocused; // Check if window is currently focused
pub const isWindowResized = c.IsWindowResized; // Check if window has been resized last frame
pub const isWindowState = c.IsWindowState; // Check if one specific window flag is enabled
pub const setWindowState = c.SetWindowState; // Set window configuration state using flags
pub const clearWindowState = c.ClearWindowState; // Clear window configuration state flags
pub const toggleFullscreen = c.ToggleFullscreen; // Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
pub const toggleBorderlessWindowed = c.ToggleBorderlessWindowed; // Toggle window state: borderless windowed, resizes window to match monitor resolution
pub const maximizeWindow = c.MaximizeWindow; // Set window state: maximized, if resizable
pub const minimizeWindow = c.MinimizeWindow; // Set window state: minimized, if resizable
pub const restoreWindow = c.RestoreWindow; // Set window state: not minimized/maximized
pub const setWindowIcon = c.SetWindowIcon; // Set icon for window (single image, RGBA 32bit)
pub const setWindowIcons = c.SetWindowIcons; // Set icon for window (multiple images, RGBA 32bit)
pub const setWindowTitle = c.SetWindowTitle; // Set title for window
pub const setWindowPosition = c.SetWindowPosition; // Set window position on screen
pub const setWindowMonitor = c.SetWindowMonitor; // Set monitor for the current window
pub const setWindowMinSize = c.SetWindowMinSize; // Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
pub const setWindowMaxSize = c.SetWindowMaxSize; // Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
pub const setWindowSize = c.SetWindowSize; // Set window dimensions
pub const setWindowOpacity = c.SetWindowOpacity; // Set window opacity [0.0f..1.0f]
pub const setWindowFocused = c.SetWindowFocused; // Set window focused
pub const getWindowHandle = c.GetWindowHandle; // Get native window handle
pub const getScreenWidth = c.GetScreenWidth; // Get current screen width
pub const getScreenHeight = c.GetScreenHeight; // Get current screen height
pub const getRenderWidth = c.GetRenderWidth; // Get current render width (it considers HiDPI)
pub const getRenderHeight = c.GetRenderHeight; // Get current render height (it considers HiDPI)
pub const getMonitorCount = c.GetMonitorCount; // Get number of connected monitors
pub const getCurrentMonitor = c.GetCurrentMonitor; // Get current monitor where window is placed
pub const getMonitorPosition = c.GetMonitorPosition; // Get specified monitor position
pub const getMonitorWidth = c.GetMonitorWidth; // Get specified monitor width (current video mode used by monitor)
pub const getMonitorHeight = c.GetMonitorHeight; // Get specified monitor height (current video mode used by monitor)
pub const getMonitorPhysicalWidth = c.GetMonitorPhysicalWidth; // Get specified monitor physical width in millimetres
pub const getMonitorPhysicalHeight = c.GetMonitorPhysicalHeight; // Get specified monitor physical height in millimetres
pub const getMonitorRefreshRate = c.GetMonitorRefreshRate; // Get specified monitor refresh rate
pub const getWindowPosition = c.GetWindowPosition; // Get window position XY on monitor
pub const getWindowScaleDPI = c.GetWindowScaleDPI; // Get window scale DPI factor
pub const getMonitorName = c.GetMonitorName; // Get the human-readable, UTF-8 encoded name of the specified monitor
pub const setClipboardText = c.SetClipboardText; // Set clipboard text content
pub const getClipboardText = c.GetClipboardText; // Get clipboard text content
pub const getClipboardImage = c.GetClipboardImage; // Get clipboard image
pub const enableEventWaiting = c.EnableEventWaiting; // Enable waiting for events on EndDrawing(), no automatic event polling
pub const disableEventWaiting = c.DisableEventWaiting; // Disable waiting for events on EndDrawing(), automatic events polling

// Cursor-related functions
pub const showCursor = c.ShowCursor; // Shows cursor
pub const hideCursor = c.HideCursor; // Hides cursor
pub const isCursorHidden = c.IsCursorHidden; // Check if cursor is not visible
pub const enableCursor = c.EnableCursor; // Enables cursor (unlock cursor)
pub const disableCursor = c.DisableCursor; // Disables cursor (lock cursor)
pub const isCursorOnScreen = c.IsCursorOnScreen; // Check if cursor is on the screen

// Drawing-related functions
pub const clearBackground = c.ClearBackground; // Set background color (framebuffer clear color)
pub const beginDrawing = c.BeginDrawing; // Setup canvas (framebuffer) to start drawing
pub const endDrawing = c.EndDrawing; // End canvas drawing and swap buffers (double buffering)
pub const beginMode2D = c.BeginMode2D; // Begin 2D mode with custom camera (2D)
pub const endMode2D = c.EndMode2D; // Ends 2D mode with custom camera
pub const beginMode3D = c.BeginMode3D; // Begin 3D mode with custom camera (3D)
pub const endMode3D = c.EndMode3D; // Ends 3D mode and returns to default 2D orthographic mode
pub const beginTextureMode = c.BeginTextureMode; // Begin drawing to render texture
pub const endTextureMode = c.EndTextureMode; // Ends drawing to render texture
pub const beginShaderMode = c.BeginShaderMode; // Begin custom shader drawing
pub const endShaderMode = c.EndShaderMode; // End custom shader drawing (use default shader)
pub const beginBlendMode = c.BeginBlendMode; // Begin blending mode (alpha, additive, multiplied, subtract, custom)
pub const endBlendMode = c.EndBlendMode; // End blending mode (reset to default: alpha blending)
pub const beginScissorMode = c.BeginScissorMode; // Begin scissor mode (define screen area for following drawing)
pub const endScissorMode = c.EndScissorMode; // End scissor mode
pub const beginVrStereoMode = c.BeginVrStereoMode; // Begin stereo rendering (requires VR simulator)
pub const endVrStereoMode = c.EndVrStereoMode; // End stereo rendering (requires VR simulator)

// VR stereo config functions for VR simulator
pub const loadVrStereoConfig = c.LoadVrStereoConfig; // Load VR stereo config for VR simulator device parameters
pub const unloadVrStereoConfig = c.UnloadVrStereoConfig; // Unload VR stereo config

// Shader management functions
// NOTE: Shader functionality is not available on OpenGL 1.1
pub const loadShader = c.LoadShader; // Load shader from files and bind default locations
pub const loadShaderFromMemory = c.LoadShaderFromMemory; // Load shader from code strings and bind default locations
pub const isShaderValid = c.IsShaderValid; // Check if a shader is valid (loaded on GPU)
pub const getShaderLocation = c.GetShaderLocation; // Get shader uniform location
pub const getShaderLocationAttrib = c.GetShaderLocationAttrib; // Get shader attribute location
pub const setShaderValue = c.SetShaderValue; // Set shader uniform value
pub const setShaderValueV = c.SetShaderValueV; // Set shader uniform value vector
pub const setShaderValueMatrix = c.SetShaderValueMatrix; // Set shader uniform value (matrix 4x4)
pub const setShaderValueTexture = c.SetShaderValueTexture; // Set shader uniform value for texture (sampler2d)
pub const unloadShader = c.UnloadShader; // Unload shader from GPU memory (VRAM)

// Screen-space-related functions
pub const getScreenToWorldRay = c.GetScreenToWorldRay; // Get a ray trace from screen position (i.e mouse)
pub const getScreenToWorldRayEx = c.GetScreenToWorldRayEx; // Get a ray trace from screen position (i.e mouse) in a viewport
pub const getWorldToScreen = c.GetWorldToScreen; // Get the screen space position for a 3d world space position
pub const getWorldToScreenEx = c.GetWorldToScreenEx; // Get size position for a 3d world space position
pub const getWorldToScreen2D = c.GetWorldToScreen2D; // Get the screen space position for a 2d camera world space position
pub const getScreenToWorld2D = c.GetScreenToWorld2D; // Get the world space position for a 2d camera screen space position
pub const getCameraMatrix = c.GetCameraMatrix; // Get camera transform matrix (view matrix)
pub const getCameraMatrix2D = c.GetCameraMatrix2D; // Get camera 2d transform matrix

// Timing-related functions
pub const setTargetFPS = c.SetTargetFPS; // Set target FPS (maximum)
pub const getFrameTime = c.GetFrameTime; // Get time in seconds for last frame drawn (delta time)
pub const getTime = c.GetTime; // Get elapsed time in seconds since InitWindow()
pub const getFPS = c.GetFPS; // Get current FPS

// Custom frame control functions
// NOTE: Those functions are intended for advanced users that want full control over the frame processing
// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
pub const swapScreenBuffer = c.SwapScreenBuffer; // Swap back buffer with front buffer (screen drawing)
pub const pollInputEvents = c.PollInputEvents; // Register all input events
pub const waitTime = c.WaitTime; // Wait for some time (halt program execution)

// Random values generation functions
pub const setRandomSeed = c.SetRandomSeed; // Set the seed for the random number generator
pub const getRandomValue = c.GetRandomValue; // Get a random value between min and max (both included)
pub const loadRandomSequence = c.LoadRandomSequence; // Load random values sequence, no values repeated
pub const unloadRandomSequence = c.UnloadRandomSequence; // Unload random values sequence

// Misc. functions
pub const takeScreenshot = c.TakeScreenshot; // Takes a screenshot of current screen (filename extension defines format)
pub const setConfigFlags = c.SetConfigFlags; // Setup init configuration flags (view FLAGS)
pub const openURL = c.OpenURL; // Open URL with default system browser (if available)

// NOTE: Following functions implemented in module [utils]
//------------------------------------------------------------------
pub const traceLog = c.TraceLog; // Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
pub const setTraceLogLevel = c.SetTraceLogLevel; // Set the current threshold (minimum) log level
pub const memAlloc = c.MemAlloc; // Internal memory allocator
pub const memRealloc = c.MemRealloc; // Internal memory reallocator
pub const memFree = c.MemFree; // Internal memory free

// Set custom callbacks
// WARNING: Callbacks setup is intended for advanced users
pub const setTraceLogCallback = c.SetTraceLogCallback; // Set custom trace log
pub const setLoadFileDataCallback = c.SetLoadFileDataCallback; // Set custom file binary data loader
pub const setSaveFileDataCallback = c.SetSaveFileDataCallback; // Set custom file binary data saver
pub const setLoadFileTextCallback = c.SetLoadFileTextCallback; // Set custom file text data loader
pub const setSaveFileTextCallback = c.SetSaveFileTextCallback; // Set custom file text data saver

// Files management functions
pub const loadFileData = c.LoadFileData; // Load file data as byte array (read)
pub const unloadFileData = c.UnloadFileData; // Unload file data allocated by LoadFileData()
pub const saveFileData = c.SaveFileData; // Save data to file from byte array (write), returns true on success
pub const exportDataAsCode = c.ExportDataAsCode; // Export data to code (.h), returns true on success
pub const loadFileText = c.LoadFileText; // Load text data from file (read), returns a '\0' terminated string
pub const unloadFileText = c.UnloadFileText; // Unload file text data allocated by LoadFileText()
pub const saveFileText = c.SaveFileText; // Save text data to file (write), string must be '\0' terminated, returns true on success
//------------------------------------------------------------------

// File system functions
pub const fileExists = c.FileExists; // Check if file exists
pub const directoryExists = c.DirectoryExists; // Check if a directory path exists
pub const isFileExtension = c.IsFileExtension; // Check file extension (including point: .png, .wav)
pub const getFileLength = c.GetFileLength; // Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
pub const getFileExtension = c.GetFileExtension; // Get pointer to extension for a filename string (includes dot: '.png')
pub const getFileName = c.GetFileName; // Get pointer to filename for a path string
pub const getFileNameWithoutExt = c.GetFileNameWithoutExt; // Get filename string without extension (uses static string)
pub const getDirectoryPath = c.GetDirectoryPath; // Get full path for a given fileName with path (uses static string)
pub const getPrevDirectoryPath = c.GetPrevDirectoryPath; // Get previous directory path for a given path (uses static string)
pub const getWorkingDirectory = c.GetWorkingDirectory; // Get current working directory (uses static string)
pub const getApplicationDirectory = c.GetApplicationDirectory; // Get the directory of the running application (uses static string)
pub const makeDirectory = c.MakeDirectory; // Create directories (including full path requested), returns 0 on success
pub const changeDirectory = c.ChangeDirectory; // Change working directory, return true on success
pub const isPathFile = c.IsPathFile; // Check if a given path is a file or a directory
pub const isFileNameValid = c.IsFileNameValid; // Check if fileName is valid for the platform/OS
pub const loadDirectoryFiles = c.LoadDirectoryFiles; // Load directory filepaths
pub const loadDirectoryFilesEx = c.LoadDirectoryFilesEx; // Load directory filepaths with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
pub const unloadDirectoryFiles = c.UnloadDirectoryFiles; // Unload filepaths
pub const isFileDropped = c.IsFileDropped; // Check if a file has been dropped into window
pub const loadDroppedFiles = c.LoadDroppedFiles; // Load dropped filepaths
pub const unloadDroppedFiles = c.UnloadDroppedFiles; // Unload dropped filepaths
pub const getFileModTime = c.GetFileModTime; // Get file modification time (last write time)

// Compression/Encoding functionality
pub const compressData = c.CompressData; // Compress data (DEFLATE algorithm), memory must be MemFree()
pub const decompressData = c.DecompressData; // Decompress data (DEFLATE algorithm), memory must be MemFree()
pub const encodeDataBase64 = c.EncodeDataBase64; // Encode data to Base64 string, memory must be MemFree()
pub const decodeDataBase64 = c.DecodeDataBase64; // Decode Base64 string data, memory must be MemFree()
pub const computeCRC32 = c.ComputeCRC32; // Compute CRC32 hash code
pub const computeMD5 = c.ComputeMD5; // Compute MD5 hash code, returns static int[4] (16 bytes)
pub const computeSHA1 = c.ComputeSHA1; // Compute SHA1 hash code, returns static int[5] (20 bytes)

// Automation events functionality
pub const loadAutomationEventList = c.LoadAutomationEventList; // Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
pub const unloadAutomationEventList = c.UnloadAutomationEventList; // Unload automation events list from file
pub const exportAutomationEventList = c.ExportAutomationEventList; // Export automation events list as text file
pub const setAutomationEventList = c.SetAutomationEventList; // Set automation event list to record to
pub const setAutomationEventBaseFrame = c.SetAutomationEventBaseFrame; // Set automation event internal base frame to start recording
pub const startAutomationEventRecording = c.StartAutomationEventRecording; // Start recording automation events (AutomationEventList must be set)
pub const stopAutomationEventRecording = c.StopAutomationEventRecording; // Stop recording automation events
pub const playAutomationEvent = c.PlayAutomationEvent; // Play a recorded automation event

//------------------------------------------------------------------------------------
// Input Handling Functions (Module: core)
//------------------------------------------------------------------------------------

// Input-related functions: keyboard
pub const isKeyPressed = c.IsKeyPressed; // Check if a key has been pressed once
pub const isKeyPressedRepeat = c.IsKeyPressedRepeat; // Check if a key has been pressed again
pub const isKeyDown = c.IsKeyDown; // Check if a key is being pressed
pub const isKeyReleased = c.IsKeyReleased; // Check if a key has been released once
pub const isKeyUp = c.IsKeyUp; // Check if a key is NOT being pressed
pub const getKeyPressed = c.GetKeyPressed; // Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
pub const getCharPressed = c.GetCharPressed; // Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
pub const setExitKey = c.SetExitKey; // Set a custom key to exit program (default is ESC)

// Input-related functions: gamepads
pub const isGamepadAvailable = c.IsGamepadAvailable; // Check if a gamepad is available
pub const getGamepadName = c.GetGamepadName; // Get gamepad internal name id
pub const isGamepadButtonPressed = c.IsGamepadButtonPressed; // Check if a gamepad button has been pressed once
pub const isGamepadButtonDown = c.IsGamepadButtonDown; // Check if a gamepad button is being pressed
pub const isGamepadButtonReleased = c.IsGamepadButtonReleased; // Check if a gamepad button has been released once
pub const isGamepadButtonUp = c.IsGamepadButtonUp; // Check if a gamepad button is NOT being pressed
pub const getGamepadButtonPressed = c.GetGamepadButtonPressed; // Get the last gamepad button pressed
pub const getGamepadAxisCount = c.GetGamepadAxisCount; // Get gamepad axis count for a gamepad
pub const getGamepadAxisMovement = c.GetGamepadAxisMovement; // Get axis movement value for a gamepad axis
pub const setGamepadMappings = c.SetGamepadMappings; // Set internal gamepad mappings (SDL_GameControllerDB)
pub const setGamepadVibration = c.SetGamepadVibration; // Set gamepad vibration for both motors (duration in seconds)

// Input-related functions: mouse
pub const isMouseButtonPressed = c.IsMouseButtonPressed; // Check if a mouse button has been pressed once
pub const isMouseButtonDown = c.IsMouseButtonDown; // Check if a mouse button is being pressed
pub const isMouseButtonReleased = c.IsMouseButtonReleased; // Check if a mouse button has been released once
pub const isMouseButtonUp = c.IsMouseButtonUp; // Check if a mouse button is NOT being pressed
pub const getMouseX = c.GetMouseX; // Get mouse position X
pub const getMouseY = c.GetMouseY; // Get mouse position Y
pub const getMousePosition = c.GetMousePosition; // Get mouse position XY
pub const getMouseDelta = c.GetMouseDelta; // Get mouse delta between frames
pub const setMousePosition = c.SetMousePosition; // Set mouse position XY
pub const setMouseOffset = c.SetMouseOffset; // Set mouse offset
pub const setMouseScale = c.SetMouseScale; // Set mouse scaling
pub const getMouseWheelMove = c.GetMouseWheelMove; // Get mouse wheel movement for X or Y, whichever is larger
pub const getMouseWheelMoveV = c.GetMouseWheelMoveV; // Get mouse wheel movement for both X and Y
pub const setMouseCursor = c.SetMouseCursor; // Set mouse cursor

// Input-related functions: touch
pub const getTouchX = c.GetTouchX; // Get touch position X for touch point 0 (relative to screen size)
pub const getTouchY = c.GetTouchY; // Get touch position Y for touch point 0 (relative to screen size)
pub const getTouchPosition = c.GetTouchPosition; // Get touch position XY for a touch point index (relative to screen size)
pub const getTouchPointId = c.GetTouchPointId; // Get touch point identifier for given index
pub const getTouchPointCount = c.GetTouchPointCount; // Get number of touch points

//------------------------------------------------------------------------------------
// Gestures and Touch Handling Functions (Module: rgestures)
//------------------------------------------------------------------------------------
pub const setGesturesEnabled = c.SetGesturesEnabled; // Enable a set of gestures using flags
pub const isGestureDetected = c.IsGestureDetected; // Check if a gesture have been detected
pub const getGestureDetected = c.GetGestureDetected; // Get latest detected gesture
pub const getGestureHoldDuration = c.GetGestureHoldDuration; // Get gesture hold time in seconds
pub const getGestureDragVector = c.GetGestureDragVector; // Get gesture drag vector
pub const getGestureDragAngle = c.GetGestureDragAngle; // Get gesture drag angle
pub const getGesturePinchVector = c.GetGesturePinchVector; // Get gesture pinch delta
pub const getGesturePinchAngle = c.GetGesturePinchAngle; // Get gesture pinch angle

//------------------------------------------------------------------------------------
// Camera System Functions (Module: rcamera)
//------------------------------------------------------------------------------------
pub const updateCamera = c.UpdateCamera; // Update camera position for selected mode
pub const updateCameraPro = c.UpdateCameraPro; // Update camera movement/rotation

// module: rshapes
// Set texture and rectangle to be used on shapes drawing
// NOTE: It can be useful when using basic shapes and one single font,
// defining a font char white rectangle would allow drawing everything in a single draw call
pub const setShapesTexture = c.SetShapesTexture; // Set texture and rectangle to be used on shapes drawing
pub const getShapesTexture = c.GetShapesTexture; // Get texture that is used for shapes drawing
pub const getShapesTextureRectangle = c.GetShapesTextureRectangle; // Get texture source rectangle that is used for shapes drawing

// Basic shapes drawing functions
pub const drawPixel = c.DrawPixel; // Draw a pixel using geometry [Can be slow, use with care]
pub const drawPixelV = c.DrawPixelV; // Draw a pixel using geometry (Vector version) [Can be slow, use with care]
pub const drawLine = c.DrawLine; // Draw a line
pub const drawLineV = c.DrawLineV; // Draw a line (using gl lines)
pub const drawLineEx = c.DrawLineEx; // Draw a line (using triangles/quads)
pub const drawLineStrip = c.DrawLineStrip; // Draw lines sequence (using gl lines)
pub const drawLineBezier = c.DrawLineBezier; // Draw line segment cubic-bezier in-out interpolation
pub const drawCircle = c.DrawCircle; // Draw a color-filled circle
pub const drawCircleSector = c.DrawCircleSector; // Draw a piece of a circle
pub const drawCircleSectorLines = c.DrawCircleSectorLines; // Draw circle sector outline
pub const drawCircleGradient = c.DrawCircleGradient; // Draw a gradient-filled circle
pub const drawCircleV = c.DrawCircleV; // Draw a color-filled circle (Vector version)
pub const drawCircleLines = c.DrawCircleLines; // Draw circle outline
pub const drawCircleLinesV = c.DrawCircleLinesV; // Draw circle outline (Vector version)
pub const drawEllipse = c.DrawEllipse; // Draw ellipse
pub const drawEllipseLines = c.DrawEllipseLines; // Draw ellipse outline
pub const drawRing = c.DrawRing; // Draw ring
pub const drawRingLines = c.DrawRingLines; // Draw ring outline
pub const drawRectangle = c.DrawRectangle; // Draw a color-filled rectangle
pub const drawRectangleV = c.DrawRectangleV; // Draw a color-filled rectangle (Vector version)
pub const drawRectangleRec = c.DrawRectangleRec; // Draw a color-filled rectangle
pub const drawRectanglePro = c.DrawRectanglePro; // Draw a color-filled rectangle with pro parameters
pub const drawRectangleGradientV = c.DrawRectangleGradientV; // Draw a vertical-gradient-filled rectangle
pub const drawRectangleGradientH = c.DrawRectangleGradientH; // Draw a horizontal-gradient-filled rectangle
pub const drawRectangleGradientEx = c.DrawRectangleGradientEx; // Draw a gradient-filled rectangle with custom vertex colors
pub const drawRectangleLines = c.DrawRectangleLines; // Draw rectangle outline
pub const drawRectangleLinesEx = c.DrawRectangleLinesEx; // Draw rectangle outline with extended parameters
pub const drawRectangleRounded = c.DrawRectangleRounded; // Draw rectangle with rounded edges
pub const drawRectangleRoundedLines = c.DrawRectangleRoundedLines; // Draw rectangle lines with rounded edges
pub const drawRectangleRoundedLinesEx = c.DrawRectangleRoundedLinesEx; // Draw rectangle with rounded edges outline
pub const drawTriangle = c.DrawTriangle; // Draw a color-filled triangle (vertex in counter-clockwise order!)
pub const drawTriangleLines = c.DrawTriangleLines; // Draw triangle outline (vertex in counter-clockwise order!)
pub const drawTriangleFan = c.DrawTriangleFan; // Draw a triangle fan defined by points (first vertex is the center)
pub const drawTriangleStrip = c.DrawTriangleStrip; // Draw a triangle strip defined by points
pub const drawPoly = c.DrawPoly; // Draw a regular polygon (Vector version)
pub const drawPolyLines = c.DrawPolyLines; // Draw a polygon outline of n sides
pub const drawPolyLinesEx = c.DrawPolyLinesEx; // Draw a polygon outline of n sides with extended parameters

// Splines drawing functions
pub const drawSplineLinear = c.DrawSplineLinear; // Draw spline: Linear, minimum 2 points
pub const drawSplineBasis = c.DrawSplineBasis; // Draw spline: B-Spline, minimum 4 points
pub const drawSplineCatmullRom = c.DrawSplineCatmullRom; // Draw spline: Catmull-Rom, minimum 4 points
pub const drawSplineBezierQuadratic = c.DrawSplineBezierQuadratic; // Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
pub const drawSplineBezierCubic = c.DrawSplineBezierCubic; // Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
pub const drawSplineSegmentLinear = c.DrawSplineSegmentLinear; // Draw spline segment: Linear, 2 points
pub const drawSplineSegmentBasis = c.DrawSplineSegmentBasis; // Draw spline segment: B-Spline, 4 points
pub const drawSplineSegmentCatmullRom = c.DrawSplineSegmentCatmullRom; // Draw spline segment: Catmull-Rom, 4 points
pub const drawSplineSegmentBezierQuadratic = c.DrawSplineSegmentBezierQuadratic; // Draw spline segment: Quadratic Bezier, 2 points, 1 control point
pub const drawSplineSegmentBezierCubic = c.DrawSplineSegmentBezierCubic; // Draw spline segment: Cubic Bezier, 2 points, 2 control points

// Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
pub const getSplinePointLinear = c.GetSplinePointLinear; // Get (evaluate) spline point: Linear
pub const getSplinePointBasis = c.GetSplinePointBasis; // Get (evaluate) spline point: B-Spline
pub const getSplinePointCatmullRom = c.GetSplinePointCatmullRom; // Get (evaluate) spline point: Catmull-Rom
pub const getSplinePointBezierQuad = c.GetSplinePointBezierQuad; // Get (evaluate) spline point: Quadratic Bezier
pub const getSplinePointBezierCubic = c.GetSplinePointBezierCubic; // Get (evaluate) spline point: Cubic Bezier

// Basic shapes collision detection functions
pub const checkCollisionRecs = c.CheckCollisionRecs; // Check collision between two rectangles
pub const checkCollisionCircles = c.CheckCollisionCircles; // Check collision between two circles
pub const checkCollisionCircleRec = c.CheckCollisionCircleRec; // Check collision between circle and rectangle
pub const checkCollisionCircleLine = c.CheckCollisionCircleLine; // Check if circle collides with a line created betweeen two points [p1] and [p2]
pub const checkCollisionPointRec = c.CheckCollisionPointRec; // Check if point is inside rectangle
pub const checkCollisionPointCircle = c.CheckCollisionPointCircle; // Check if point is inside circle
pub const checkCollisionPointTriangle = c.CheckCollisionPointTriangle; // Check if point is inside a triangle
pub const checkCollisionPointLine = c.CheckCollisionPointLine; // Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
pub const checkCollisionPointPoly = c.CheckCollisionPointPoly; // Check if point is within a polygon described by array of vertices
pub const checkCollisionLines = c.CheckCollisionLines; // Check the collision between two lines defined by two points each, returns collision point by reference
pub const getCollisionRec = c.GetCollisionRec; // Get collision rectangle for two rectangles collision

// module: rtextures
// Image loading functions
// NOTE: These functions do not require GPU access
pub const loadImage = c.LoadImage; // Load image from file into CPU memory (RAM)
pub const loadImageRaw = c.LoadImageRaw; // Load image from RAW file data
pub const loadImageAnim = c.LoadImageAnim; // Load image sequence from file (frames appended to image.data)
pub const loadImageAnimFromMemory = c.LoadImageAnimFromMemory; // Load image sequence from memory buffer
pub const loadImageFromMemory = c.LoadImageFromMemory; // Load image from memory buffer, fileType refers to extension: i.e. '.png'
pub const loadImageFromTexture = c.LoadImageFromTexture; // Load image from GPU texture data
pub const loadImageFromScreen = c.LoadImageFromScreen; // Load image from screen buffer and (screenshot)
pub const isImageValid = c.IsImageValid; // Check if an image is valid (data and parameters)
pub const unloadImage = c.UnloadImage; // Unload image from CPU memory (RAM)
pub const exportImage = c.ExportImage; // Export image data to file, returns true on success
pub const exportImageToMemory = c.ExportImageToMemory; // Export image to memory buffer
pub const exportImageAsCode = c.ExportImageAsCode; // Export image as code file defining an array of bytes, returns true on success

// Image generation functions
pub const genImageColor = c.GenImageColor; // Generate image: plain color
pub const genImageGradientLinear = c.GenImageGradientLinear; // Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
pub const genImageGradientRadial = c.GenImageGradientRadial; // Generate image: radial gradient
pub const genImageGradientSquare = c.GenImageGradientSquare; // Generate image: square gradient
pub const genImageChecked = c.GenImageChecked; // Generate image: checked
pub const genImageWhiteNoise = c.GenImageWhiteNoise; // Generate image: white noise
pub const genImagePerlinNoise = c.GenImagePerlinNoise; // Generate image: perlin noise
pub const genImageCellular = c.GenImageCellular; // Generate image: cellular algorithm, bigger tileSize means bigger cells
pub const genImageText = c.GenImageText; // Generate image: grayscale image from text data

// Image manipulation functions
pub const imageCopy = c.ImageCopy; // Create an image duplicate (useful for transformations)
pub const imageFromImage = c.ImageFromImage; // Create an image from another image piece
pub const imageFromChannel = c.ImageFromChannel; // Create an image from a selected channel of another image (GRAYSCALE)
pub const imageText = c.ImageText; // Create an image from text (default font)
pub const imageTextEx = c.ImageTextEx; // Create an image from text (custom sprite font)
pub const imageFormat = c.ImageFormat; // Convert image data to desired format
pub const imageToPOT = c.ImageToPOT; // Convert image to POT (power-of-two)
pub const imageCrop = c.ImageCrop; // Crop an image to a defined rectangle
pub const imageAlphaCrop = c.ImageAlphaCrop; // Crop image depending on alpha value
pub const imageAlphaClear = c.ImageAlphaClear; // Clear alpha channel to desired color
pub const imageAlphaMask = c.ImageAlphaMask; // Apply alpha mask to image
pub const imageAlphaPremultiply = c.ImageAlphaPremultiply; // Premultiply alpha channel
pub const imageBlurGaussian = c.ImageBlurGaussian; // Apply Gaussian blur using a box blur approximation
pub const imageKernelConvolution = c.ImageKernelConvolution; // Apply custom square convolution kernel to image
pub const imageResize = c.ImageResize; // Resize image (Bicubic scaling algorithm)
pub const imageResizeNN = c.ImageResizeNN; // Resize image (Nearest-Neighbor scaling algorithm)
pub const imageResizeCanvas = c.ImageResizeCanvas; // Resize canvas and fill with color
pub const imageMipmaps = c.ImageMipmaps; // Compute all mipmap levels for a provided image
pub const imageDither = c.ImageDither; // Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
pub const imageFlipVertical = c.ImageFlipVertical; // Flip image vertically
pub const imageFlipHorizontal = c.ImageFlipHorizontal; // Flip image horizontally
pub const imageRotate = c.ImageRotate; // Rotate image by input angle in degrees (-359 to 359)
pub const imageRotateCW = c.ImageRotateCW; // Rotate image clockwise 90deg
pub const imageRotateCCW = c.ImageRotateCCW; // Rotate image counter-clockwise 90deg
pub const imageColorTint = c.ImageColorTint; // Modify image color: tint
pub const imageColorInvert = c.ImageColorInvert; // Modify image color: invert
pub const imageColorGrayscale = c.ImageColorGrayscale; // Modify image color: grayscale
pub const imageColorContrast = c.ImageColorContrast; // Modify image color: contrast (-100 to 100)
pub const imageColorBrightness = c.ImageColorBrightness; // Modify image color: brightness (-255 to 255)
pub const imageColorReplace = c.ImageColorReplace; // Modify image color: replace color
pub const loadImageColors = c.LoadImageColors; // Load color data from image as a Color array (RGBA - 32bit)
pub const loadImagePalette = c.LoadImagePalette; // Load colors palette from image as a Color array (RGBA - 32bit)
pub const unloadImageColors = c.UnloadImageColors; // Unload color data loaded with LoadImageColors()
pub const unloadImagePalette = c.UnloadImagePalette; // Unload colors palette loaded with LoadImagePalette()
pub const getImageAlphaBorder = c.GetImageAlphaBorder; // Get image alpha border rectangle
pub const getImageColor = c.GetImageColor; // Get image pixel color at (x, y) position

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)
pub const imageClearBackground = c.ImageClearBackground; // Clear image background with given color
pub const imageDrawPixel = c.ImageDrawPixel; // Draw pixel within an image
pub const imageDrawPixelV = c.ImageDrawPixelV; // Draw pixel within an image (Vector version)
pub const imageDrawLine = c.ImageDrawLine; // Draw line within an image
pub const imageDrawLineV = c.ImageDrawLineV; // Draw line within an image (Vector version)
pub const imageDrawLineEx = c.ImageDrawLineEx; // Draw a line defining thickness within an image
pub const imageDrawCircle = c.ImageDrawCircle; // Draw a filled circle within an image
pub const imageDrawCircleV = c.ImageDrawCircleV; // Draw a filled circle within an image (Vector version)
pub const imageDrawCircleLines = c.ImageDrawCircleLines; // Draw circle outline within an image
pub const imageDrawCircleLinesV = c.ImageDrawCircleLinesV; // Draw circle outline within an image (Vector version)
pub const imageDrawRectangle = c.ImageDrawRectangle; // Draw rectangle within an image
pub const imageDrawRectangleV = c.ImageDrawRectangleV; // Draw rectangle within an image (Vector version)
pub const imageDrawRectangleRec = c.ImageDrawRectangleRec; // Draw rectangle within an image
pub const imageDrawRectangleLines = c.ImageDrawRectangleLines; // Draw rectangle lines within an image
pub const imageDrawTriangle = c.ImageDrawTriangle; // Draw triangle within an image
pub const imageDrawTriangleEx = c.ImageDrawTriangleEx; // Draw triangle with interpolated colors within an image
pub const imageDrawTriangleLines = c.ImageDrawTriangleLines; // Draw triangle outline within an image
pub const imageDrawTriangleFan = c.ImageDrawTriangleFan; // Draw a triangle fan defined by points within an image (first vertex is the center)
pub const imageDrawTriangleStrip = c.ImageDrawTriangleStrip; // Draw a triangle strip defined by points within an image
pub const imageDraw = c.ImageDraw; // Draw a source image within a destination image (tint applied to source)
pub const imageDrawText = c.ImageDrawText; // Draw text (using default font) within an image (destination)
pub const imageDrawTextEx = c.ImageDrawTextEx; // Draw text (custom sprite font) within an image (destination)

// Texture loading functions
// NOTE: These functions require GPU access
pub const loadTexture = c.LoadTexture; // Load texture from file into GPU memory (VRAM)
pub const loadTextureFromImage = c.LoadTextureFromImage; // Load texture from image data
pub const loadTextureCubemap = c.LoadTextureCubemap; // Load cubemap from image, multiple image cubemap layouts supported
pub const loadRenderTexture = c.LoadRenderTexture; // Load texture for rendering (framebuffer)
pub const isTextureValid = c.IsTextureValid; // Check if a texture is valid (loaded in GPU)
pub const unloadTexture = c.UnloadTexture; // Unload texture from GPU memory (VRAM)
pub const isRenderTextureValid = c.IsRenderTextureValid; // Check if a render texture is valid (loaded in GPU)
pub const unloadRenderTexture = c.UnloadRenderTexture; // Unload render texture from GPU memory (VRAM)
pub const updateTexture = c.UpdateTexture; // Update GPU texture with new data
pub const updateTextureRec = c.UpdateTextureRec; // Update GPU texture rectangle with new data

// Texture configuration functions
pub const genTextureMipmaps = c.GenTextureMipmaps; // Generate GPU mipmaps for a texture
pub const setTextureFilter = c.SetTextureFilter; // Set texture scaling filter mode
pub const setTextureWrap = c.SetTextureWrap; // Set texture wrapping mode

// Texture drawing functions
pub const drawTexture = c.DrawTexture; // Draw a Texture2D
pub const drawTextureV = c.DrawTextureV; // Draw a Texture2D with position defined as Vector2
pub const drawTextureEx = c.DrawTextureEx; // Draw a Texture2D with extended parameters
pub const drawTextureRec = c.DrawTextureRec; // Draw a part of a texture defined by a rectangle
pub const drawTexturePro = c.DrawTexturePro; // Draw a part of a texture defined by a rectangle with 'pro' parameters
pub const drawTextureNPatch = c.DrawTextureNPatch; // Draws a texture (or part of it) that stretches or shrinks nicely

// Color/pixel related functions
pub const colorIsEqual = c.ColorIsEqual; // Check if two colors are equal
pub const fade = c.Fade; // Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub const colorToInt = c.ColorToInt; // Get hexadecimal value for a Color (0xRRGGBBAA)
pub const colorNormalize = c.ColorNormalize; // Get Color normalized as float [0..1]
pub const colorFromNormalized = c.ColorFromNormalized; // Get Color from normalized values [0..1]
pub const colorToHSV = c.ColorToHSV; // Get HSV values for a Color, hue [0..360], saturation/value [0..1]
pub const colorFromHSV = c.ColorFromHSV; // Get a Color from HSV values, hue [0..360], saturation/value [0..1]
pub const colorTint = c.ColorTint; // Get color multiplied with another color
pub const colorBrightness = c.ColorBrightness; // Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
pub const colorContrast = c.ColorContrast; // Get color with contrast correction, contrast values between -1.0f and 1.0f
pub const colorAlpha = c.ColorAlpha; // Get color with alpha applied, alpha goes from 0.0f to 1.0f
pub const colorAlphaBlend = c.ColorAlphaBlend; // Get src alpha-blended into dst color with tint
pub const colorLerp = c.ColorLerp; // Get color lerp interpolation between two colors, factor [0.0f..1.0f]
// pub const getColor = c.GetColor; // Get Color structure from hexadecimal value
pub const getPixelColor = c.GetPixelColor; // Get Color from a source pixel pointer of certain format
pub const setPixelColor = c.SetPixelColor; // Set color formatted into destination pixel pointer
pub const getPixelDataSize = c.GetPixelDataSize; // Get pixel data size in bytes for certain format

// module: rtext
// Font loading/unloading functions
pub const getFontDefault = c.GetFontDefault; // Get the default Font
pub const loadFont = c.LoadFont; // Load font from file into GPU memory (VRAM)
pub const loadFontEx = c.LoadFontEx; // Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
pub const loadFontFromImage = c.LoadFontFromImage; // Load font from Image (XNA style)
pub const loadFontFromMemory = c.LoadFontFromMemory; // Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
pub const isFontValid = c.IsFontValid; // Check if a font is valid (font data loaded, WARNING: GPU texture not checked)
pub const loadFontData = c.LoadFontData; // Load font data for further use
pub const genImageFontAtlas = c.GenImageFontAtlas; // Generate image font atlas using chars info
pub const unloadFontData = c.UnloadFontData; // Unload font chars info data (RAM)
pub const unloadFont = c.UnloadFont; // Unload font from GPU memory (VRAM)
pub const exportFontAsCode = c.ExportFontAsCode; // Export font as code file, returns true on success

// Text drawing functions
pub const drawFPS = c.DrawFPS; // Draw current FPS
pub const drawText = c.DrawText; // Draw text (using default font)
pub const drawTextEx = c.DrawTextEx; // Draw text using font and additional parameters
pub const drawTextPro = c.DrawTextPro; // Draw text using Font and pro parameters (rotation)
pub const drawTextCodepoint = c.DrawTextCodepoint; // Draw one character (codepoint)
pub const drawTextCodepoints = c.DrawTextCodepoints; // Draw multiple character (codepoint)

// Text font info functions
pub const setTextLineSpacing = c.SetTextLineSpacing; // Set vertical line spacing when drawing with line-breaks
pub const measureText = c.MeasureText; // Measure string width for default font
pub const measureTextEx = c.MeasureTextEx; // Measure string size for Font
pub const getGlyphIndex = c.GetGlyphIndex; // Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
pub const getGlyphInfo = c.GetGlyphInfo; // Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
pub const getGlyphAtlasRec = c.GetGlyphAtlasRec; // Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

// Text codepoints management functions (unicode characters)
pub const loadUTF8 = c.LoadUTF8; // Load UTF-8 text encoded from codepoints array
pub const unloadUTF8 = c.UnloadUTF8; // Unload UTF-8 text encoded from codepoints array
pub const loadCodepoints = c.LoadCodepoints; // Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
pub const unloadCodepoints = c.UnloadCodepoints; // Unload codepoints data from memory
pub const getCodepointCount = c.GetCodepointCount; // Get total number of codepoints in a UTF-8 encoded string
pub const getCodepoint = c.GetCodepoint; // Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
pub const getCodepointNext = c.GetCodepointNext; // Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
pub const getCodepointPrevious = c.GetCodepointPrevious; // Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
pub const codepointToUTF8 = c.CodepointToUTF8; // Encode one codepoint into UTF-8 byte array (array length returned as parameter)

// Text strings management functions (no UTF-8 strings, only byte chars)
// NOTE: Some strings allocate memory internally for returned strings, just be careful!
pub const textCopy = c.TextCopy; // Copy one string to another, returns bytes copied
pub const textIsEqual = c.TextIsEqual; // Check if two text string are equal
pub const textLength = c.TextLength; // Get text length, checks for '\0' ending
pub const textFormat = c.TextFormat; // Text formatting with variables (sprintf() style)
pub const textSubtext = c.TextSubtext; // Get a piece of a text string
pub const textReplace = c.TextReplace; // Replace text string (WARNING: memory must be freed!)
pub const textInsert = c.TextInsert; // Insert text in a position (WARNING: memory must be freed!)
pub const textJoin = c.TextJoin; // Join text strings with delimiter
pub const textSplit = c.TextSplit; // Split text into multiple strings
pub const textAppend = c.TextAppend; // Append text at specific position and move cursor!
pub const textFindIndex = c.TextFindIndex; // Find first text occurrence within a string
pub const textToUpper = c.TextToUpper; // Get upper case version of provided string
pub const textToLower = c.TextToLower; // Get lower case version of provided string
pub const textToPascal = c.TextToPascal; // Get Pascal case notation version of provided string
pub const textToSnake = c.TextToSnake; // Get Snake case notation version of provided string
pub const textToCamel = c.TextToCamel; // Get Camel case notation version of provided string

pub const textToInteger = c.TextToInteger; // Get integer value from text (negative values not supported)
pub const textToFloat = c.TextToFloat; // Get float value from text (negative values not supported)

// module: rmodels
// Basic geometric 3D shapes drawing functions
pub const drawLine3D = c.DrawLine3D; // Draw a line in 3D world space
pub const drawPoint3D = c.DrawPoint3D; // Draw a point in 3D space, actually a small line
pub const drawCircle3D = c.DrawCircle3D; // Draw a circle in 3D world space
pub const drawTriangle3D = c.DrawTriangle3D; // Draw a color-filled triangle (vertex in counter-clockwise order!)
pub const drawTriangleStrip3D = c.DrawTriangleStrip3D; // Draw a triangle strip defined by points
pub const drawCube = c.DrawCube; // Draw cube
pub const drawCubeV = c.DrawCubeV; // Draw cube (Vector version)
pub const drawCubeWires = c.DrawCubeWires; // Draw cube wires
pub const drawCubeWiresV = c.DrawCubeWiresV; // Draw cube wires (Vector version)
pub const drawSphere = c.DrawSphere; // Draw sphere
pub const drawSphereEx = c.DrawSphereEx; // Draw sphere with extended parameters
pub const drawSphereWires = c.DrawSphereWires; // Draw sphere wires
pub const drawCylinder = c.DrawCylinder; // Draw a cylinder/cone
pub const drawCylinderEx = c.DrawCylinderEx; // Draw a cylinder with base at startPos and top at endPos
pub const drawCylinderWires = c.DrawCylinderWires; // Draw a cylinder/cone wires
pub const drawCylinderWiresEx = c.DrawCylinderWiresEx; // Draw a cylinder wires with base at startPos and top at endPos
pub const drawCapsule = c.DrawCapsule; // Draw a capsule with the center of its sphere caps at startPos and endPos
pub const drawCapsuleWires = c.DrawCapsuleWires; // Draw capsule wireframe with the center of its sphere caps at startPos and endPos
pub const drawPlane = c.DrawPlane; // Draw a plane XZ
pub const drawRay = c.DrawRay; // Draw a ray line
pub const drawGrid = c.DrawGrid; // Draw a grid (centered at (0, 0, 0))

//------------------------------------------------------------------------------------
// Model 3d Loading and Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Model management functions
pub const loadModel = c.LoadModel; // Load model from files (meshes and materials)
pub const loadModelFromMesh = c.LoadModelFromMesh; // Load model from generated mesh (default material)
pub const isModelValid = c.IsModelValid; // Check if a model is valid (loaded in GPU, VAO/VBOs)
pub const unloadModel = c.UnloadModel; // Unload model (including meshes) from memory (RAM and/or VRAM)
pub const getModelBoundingBox = c.GetModelBoundingBox; // Compute model bounding box limits (considers all meshes)

// Model drawing functions
pub const drawModel = c.DrawModel; // Draw a model (with texture if set)
pub const drawModelEx = c.DrawModelEx; // Draw a model with extended parameters
pub const drawModelWires = c.DrawModelWires; // Draw a model wires (with texture if set)
pub const drawModelWiresEx = c.DrawModelWiresEx; // Draw a model wires (with texture if set) with extended parameters
pub const drawModelPoints = c.DrawModelPoints; // Draw a model as points
pub const drawModelPointsEx = c.DrawModelPointsEx; // Draw a model as points with extended parameters
pub const drawBoundingBox = c.DrawBoundingBox; // Draw bounding box (wires)
pub const drawBillboard = c.DrawBillboard; // Draw a billboard texture
pub const drawBillboardRec = c.DrawBillboardRec; // Draw a billboard texture defined by source
pub const drawBillboardPro = c.DrawBillboardPro; // Draw a billboard texture defined by source and rotation

// Mesh management functions
pub const uploadMesh = c.UploadMesh; // Upload mesh vertex data in GPU and provide VAO/VBO ids
pub const updateMeshBuffer = c.UpdateMeshBuffer; // Update mesh vertex data in GPU for a specific buffer index
pub const unloadMesh = c.UnloadMesh; // Unload mesh data from CPU and GPU
pub const drawMesh = c.DrawMesh; // Draw a 3d mesh with material and transform
pub const drawMeshInstanced = c.DrawMeshInstanced; // Draw multiple mesh instances with material and different transforms
pub const getMeshBoundingBox = c.GetMeshBoundingBox; // Compute mesh bounding box limits
pub const genMeshTangents = c.GenMeshTangents; // Compute mesh tangents
pub const exportMesh = c.ExportMesh; // Export mesh data to file, returns true on success
pub const exportMeshAsCode = c.ExportMeshAsCode; // Export mesh as code file (.h) defining multiple arrays of vertex attributes

// Mesh generation functions
pub const genMeshPoly = c.GenMeshPoly; // Generate polygonal mesh
pub const genMeshPlane = c.GenMeshPlane; // Generate plane mesh (with subdivisions)
pub const genMeshCube = c.GenMeshCube; // Generate cuboid mesh
pub const genMeshSphere = c.GenMeshSphere; // Generate sphere mesh (standard sphere)
pub const genMeshHemiSphere = c.GenMeshHemiSphere; // Generate half-sphere mesh (no bottom cap)
pub const genMeshCylinder = c.GenMeshCylinder; // Generate cylinder mesh
pub const genMeshCone = c.GenMeshCone; // Generate cone/pyramid mesh
pub const genMeshTorus = c.GenMeshTorus; // Generate torus mesh
pub const genMeshKnot = c.GenMeshKnot; // Generate trefoil knot mesh
pub const genMeshHeightmap = c.GenMeshHeightmap; // Generate heightmap mesh from image data
pub const genMeshCubicmap = c.GenMeshCubicmap; // Generate cubes-based map mesh from image data

// Material loading/unloading functions
pub const loadMaterials = c.LoadMaterials; // Load materials from model file
pub const loadMaterialDefault = c.LoadMaterialDefault; // Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
pub const isMaterialValid = c.IsMaterialValid; // Check if a material is valid (shader assigned, map textures loaded in GPU)
pub const unloadMaterial = c.UnloadMaterial; // Unload material from GPU memory (VRAM)
pub const setMaterialTexture = c.SetMaterialTexture; // Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
pub const setModelMeshMaterial = c.SetModelMeshMaterial; // Set material for a mesh

// Model animations loading/unloading functions
pub const loadModelAnimations = c.LoadModelAnimations; // Load model animations from file
pub const updateModelAnimation = c.UpdateModelAnimation; // Update model animation pose (CPU)
pub const updateModelAnimationBones = c.UpdateModelAnimationBones; // Update model animation mesh bone matrices (GPU skinning)
pub const unloadModelAnimation = c.UnloadModelAnimation; // Unload animation data
pub const unloadModelAnimations = c.UnloadModelAnimations; // Unload animation array data
pub const isModelAnimationValid = c.IsModelAnimationValid; // Check model animation skeleton match

// Collision detection functions
pub const checkCollisionSpheres = c.CheckCollisionSpheres; // Check collision between two spheres
pub const checkCollisionBoxes = c.CheckCollisionBoxes; // Check collision between two bounding boxes
pub const checkCollisionBoxSphere = c.CheckCollisionBoxSphere; // Check collision between box and sphere
pub const getRayCollisionSphere = c.GetRayCollisionSphere; // Get collision info between ray and sphere
pub const getRayCollisionBox = c.GetRayCollisionBox; // Get collision info between ray and box
pub const getRayCollisionMesh = c.GetRayCollisionMesh; // Get collision info between ray and mesh
pub const getRayCollisionTriangle = c.GetRayCollisionTriangle; // Get collision info between ray and triangle
pub const getRayCollisionQuad = c.GetRayCollisionQuad; // Get collision info between ray and quad

// module: raudio
// Audio device management functions
pub const initAudioDevice = c.InitAudioDevice; // Initialize audio device and context
pub const closeAudioDevice = c.CloseAudioDevice; // Close the audio device and context
pub const isAudioDeviceReady = c.IsAudioDeviceReady; // Check if audio device has been initialized successfully
pub const setMasterVolume = c.SetMasterVolume; // Set master volume (listener)
pub const getMasterVolume = c.GetMasterVolume; // Get master volume (listener)

// Wave/Sound loading/unloading functions
pub const loadWave = c.LoadWave; // Load wave data from file
pub const loadWaveFromMemory = c.LoadWaveFromMemory; // Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
pub const isWaveValid = c.IsWaveValid; // Checks if wave data is valid (data loaded and parameters)
pub const loadSound = c.LoadSound; // Load sound from file
pub const loadSoundFromWave = c.LoadSoundFromWave; // Load sound from wave data
pub const loadSoundAlias = c.LoadSoundAlias; // Create a new sound that shares the same sample data as the source sound, does not own the sound data
pub const isSoundValid = c.IsSoundValid; // Checks if a sound is valid (data loaded and buffers initialized)
pub const updateSound = c.UpdateSound; // Update sound buffer with new data
pub const unloadWave = c.UnloadWave; // Unload wave data
pub const unloadSound = c.UnloadSound; // Unload sound
pub const unloadSoundAlias = c.UnloadSoundAlias; // Unload a sound alias (does not deallocate sample data)
pub const exportWave = c.ExportWave; // Export wave data to file, returns true on success
pub const exportWaveAsCode = c.ExportWaveAsCode; // Export wave sample data to code (.h), returns true on success

// Wave/Sound management functions
pub const playSound = c.PlaySound; // Play a sound
pub const stopSound = c.StopSound; // Stop playing a sound
pub const pauseSound = c.PauseSound; // Pause a sound
pub const resumeSound = c.ResumeSound; // Resume a paused sound
pub const isSoundPlaying = c.IsSoundPlaying; // Check if a sound is currently playing
pub const setSoundVolume = c.SetSoundVolume; // Set volume for a sound (1.0 is max level)
pub const setSoundPitch = c.SetSoundPitch; // Set pitch for a sound (1.0 is base level)
pub const setSoundPan = c.SetSoundPan; // Set pan for a sound (0.5 is center)
pub const waveCopy = c.WaveCopy; // Copy a wave to a new wave
pub const waveCrop = c.WaveCrop; // Crop a wave to defined frames range
pub const waveFormat = c.WaveFormat; // Convert wave data to desired format
pub const loadWaveSamples = c.LoadWaveSamples; // Load samples data from wave as a 32bit float data array
pub const unloadWaveSamples = c.UnloadWaveSamples; // Unload samples data loaded with LoadWaveSamples()

// Music management functions
pub const loadMusicStream = c.LoadMusicStream; // Load music stream from file
pub const loadMusicStreamFromMemory = c.LoadMusicStreamFromMemory; // Load music stream from data
pub const isMusicValid = c.IsMusicValid; // Checks if a music stream is valid (context and buffers initialized)
pub const unloadMusicStream = c.UnloadMusicStream; // Unload music stream
pub const playMusicStream = c.PlayMusicStream; // Start music playing
pub const isMusicStreamPlaying = c.IsMusicStreamPlaying; // Check if music is playing
pub const updateMusicStream = c.UpdateMusicStream; // Updates buffers for music streaming
pub const stopMusicStream = c.StopMusicStream; // Stop music playing
pub const pauseMusicStream = c.PauseMusicStream; // Pause music playing
pub const resumeMusicStream = c.ResumeMusicStream; // Resume playing paused music
pub const seekMusicStream = c.SeekMusicStream; // Seek music to a position (in seconds)
pub const setMusicVolume = c.SetMusicVolume; // Set volume for music (1.0 is max level)
pub const setMusicPitch = c.SetMusicPitch; // Set pitch for a music (1.0 is base level)
pub const setMusicPan = c.SetMusicPan; // Set pan for a music (0.5 is center)
pub const getMusicTimeLength = c.GetMusicTimeLength; // Get music time length (in seconds)
pub const getMusicTimePlayed = c.GetMusicTimePlayed; // Get current music time played (in seconds)

// AudioStream management functions
pub const loadAudioStream = c.LoadAudioStream; // Load audio stream (to stream raw audio pcm data)
pub const isAudioStreamValid = c.IsAudioStreamValid; // Checks if an audio stream is valid (buffers initialized)
pub const unloadAudioStream = c.UnloadAudioStream; // Unload audio stream and free memory
pub const updateAudioStream = c.UpdateAudioStream; // Update audio stream buffers with data
pub const isAudioStreamProcessed = c.IsAudioStreamProcessed; // Check if any audio stream buffers requires refill
pub const playAudioStream = c.PlayAudioStream; // Play audio stream
pub const pauseAudioStream = c.PauseAudioStream; // Pause audio stream
pub const resumeAudioStream = c.ResumeAudioStream; // Resume audio stream
pub const isAudioStreamPlaying = c.IsAudioStreamPlaying; // Check if audio stream is playing
pub const stopAudioStream = c.StopAudioStream; // Stop audio stream
pub const setAudioStreamVolume = c.SetAudioStreamVolume; // Set volume for audio stream (1.0 is max level)
pub const setAudioStreamPitch = c.SetAudioStreamPitch; // Set pitch for audio stream (1.0 is base level)
pub const setAudioStreamPan = c.SetAudioStreamPan; // Set pan for audio stream (0.5 is centered)
pub const setAudioStreamBufferSizeDefault = c.SetAudioStreamBufferSizeDefault; // Default size for new audio streams
pub const setAudioStreamCallback = c.SetAudioStreamCallback; // Audio thread callback to request new data

pub const attachAudioStreamProcessor = c.AttachAudioStreamProcessor; // Attach audio stream processor to stream, receives the samples as 'float'
pub const detachAudioStreamProcessor = c.DetachAudioStreamProcessor; // Detach audio stream processor from stream

pub const attachAudioMixedProcessor = c.AttachAudioMixedProcessor; // Attach audio stream processor to the entire audio pipeline, receives the samples as 'float'
pub const detachAudioMixedProcessor = c.DetachAudioMixedProcessor; // Detach audio stream processor from the entire audio pipeline

// module: raymath
// Utils math
pub const clamp = c.Clamp; // Clamp float value
pub const lerp = c.Lerp; // Calculate linear interpolation between two floats
pub const normalize = c.Normalize; // Normalize input value within input range
pub const remap = c.Remap; // Remap input value within input range to output range
pub const wrap = c.Wrap; // Wrap input value from min to max
pub const floatEquals = c.FloatEquals; // Check whether two given floats are almost equal

// Vector2 math
pub const vector2Zero = c.Vector2Zero; // Vector with components value 0.0f
pub const vector2One = c.Vector2One; // Vector with components value 1.0f
pub const vector2Add = c.Vector2Add; // Add two vectors (v1 + v2)
pub const vector2AddValue = c.Vector2AddValue; // Add vector and float value
pub const vector2Subtract = c.Vector2Subtract; // Subtract two vectors (v1 - v2)
pub const vector2SubtractValue = c.Vector2SubtractValue; // Subtract vector by float value
pub const vector2Length = c.Vector2Length; // Calculate vector length
pub const vector2LengthSqr = c.Vector2LengthSqr; // Calculate vector square length
pub const vector2DotProduct = c.Vector2DotProduct; // Calculate two vectors dot product
pub const vector2Distance = c.Vector2Distance; // Calculate distance between two vectors
pub const vector2DistanceSqr = c.Vector2DistanceSqr; // Calculate square distance between two vectors
pub const vector2Angle = c.Vector2Angle; // Calculate angle from two vectors
pub const vector2Scale = c.Vector2Scale; // Scale vector (multiply by value)
pub const vector2Multiply = c.Vector2Multiply; // Multiply vector by vector
pub const vector2Negate = c.Vector2Negate; // Negate vector
pub const vector2Divide = c.Vector2Divide; // Divide vector by vector
pub const vector2Normalize = c.Vector2Normalize; // Normalize provided vector
pub const vector2Transform = c.Vector2Transform; // Transforms a Vector2 by a given Matrix
pub const vector2Lerp = c.Vector2Lerp; // Calculate linear interpolation between two vectors
pub const vector2Reflect = c.Vector2Reflect; // Calculate reflected vector to normal
pub const vector2Rotate = c.Vector2Rotate; // Rotate vector by angle
pub const vector2MoveTowards = c.Vector2MoveTowards; // Move Vector towards target
pub const vector2Invert = c.Vector2Invert; // Invert the given vector
pub const vector2Clamp = c.Vector2Clamp; // Clamp the components of the vector between min and max values specified by the given vectors
pub const vector2ClampValue = c.Vector2ClampValue; // Clamp the magnitude of the vector between two min and max values
pub const vector2Equals = c.Vector2Equals; // Check whether two given vectors are almost equal

// Vector3 math
pub const vector3Zero = c.Vector3Zero; // Vector with components value 0.0f
pub const vector3One = c.Vector3One; // Vector with components value 1.0f
pub const vector3Add = c.Vector3Add; // Add two vectors
pub const vector3AddValue = c.Vector3AddValue; // Add vector and float value
pub const vector3Subtract = c.Vector3Subtract; // Subtract two vectors
pub const vector3SubtractValue = c.Vector3SubtractValue; // Subtract vector by float value
pub const vector3Scale = c.Vector3Scale; // Multiply vector by scalar
pub const vector3Multiply = c.Vector3Multiply; // Multiply vector by vector
pub const vector3CrossProduct = c.Vector3CrossProduct; // Calculate two vectors cross product
pub const vector3Perpendicular = c.Vector3Perpendicular; // Calculate one vector perpendicular vector
pub const vector3Length = c.Vector3Length; // Calculate vector length
pub const vector3LengthSqr = c.Vector3LengthSqr; // Calculate vector square length
pub const vector3DotProduct = c.Vector3DotProduct; // Calculate two vectors dot product
pub const vector3Distance = c.Vector3Distance; // Calculate distance between two vectors
pub const vector3DistanceSqr = c.Vector3DistanceSqr; // Calculate square distance between two vectors
pub const vector3Angle = c.Vector3Angle; // Calculate angle between two vectors
pub const vector3Negate = c.Vector3Negate; // Negate provided vector (invert direction)
pub const vector3Divide = c.Vector3Divide; // Divide vector by vector
pub const vector3Normalize = c.Vector3Normalize; // Normalize provided vector
pub const vector3OrthoNormalize = c.Vector3OrthoNormalize; // Orthonormalize provided vectors Makes vectors normalized and orthogonal to each other Gram-Schmidt function implementation
pub const vector3Transform = c.Vector3Transform; // Transforms a Vector3 by a given Matrix
pub const vector3RotateByQuaternion = c.Vector3RotateByQuaternion; // Transform a vector by quaternion rotation
pub const vector3RotateByAxisAngle = c.Vector3RotateByAxisAngle; // Rotates a vector around an axis
pub const vector3Lerp = c.Vector3Lerp; // Calculate linear interpolation between two vectors
pub const vector3Reflect = c.Vector3Reflect; // Calculate reflected vector to normal
pub const vector3Min = c.Vector3Min; // Get min value for each pair of components
pub const vector3Max = c.Vector3Max; // Get max value for each pair of components
pub const vector3Barycenter = c.Vector3Barycenter; // Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c) NOTE: Assumes P is on the plane of the triangle
pub const vector3Unproject = c.Vector3Unproject; // Projects a Vector3 from screen space into object space NOTE: We are avoiding calling other raymath functions despite available
pub const vector3ToFloatV = c.Vector3ToFloatV; // Get Vector3 as float array
pub const vector3Invert = c.Vector3Invert; // Invert the given vector
pub const vector3Clamp = c.Vector3Clamp; // Clamp the components of the vector between min and max values specified by the given vectors
pub const vector3ClampValue = c.Vector3ClampValue; // Clamp the magnitude of the vector between two values
pub const vector3Equals = c.Vector3Equals; // Check whether two given vectors are almost equal
pub const vector3Refract = c.Vector3Refract; // Compute the direction of a refracted ray where v specifies the normalized direction of the incoming ray, n specifies the normalized normal vector of the interface of two optical media, and r specifies the ratio of the refractive index of the medium from where the ray comes to the refractive index of the medium on the other side of the surface

// Matrix math
pub const matrixDeterminant = c.MatrixDeterminant; // Compute matrix determinant
pub const matrixTrace = c.MatrixTrace; // Get the trace of the matrix (sum of the values along the diagonal)
pub const matrixTranspose = c.MatrixTranspose; // Transposes provided matrix
pub const matrixInvert = c.MatrixInvert; // Invert provided matrix
pub const matrixIdentity = c.MatrixIdentity; // Get identity matrix
pub const matrixAdd = c.MatrixAdd; // Add two matrices
pub const matrixSubtract = c.MatrixSubtract; // Subtract two matrices (left - right)
pub const matrixMultiply = c.MatrixMultiply; // Get two matrix multiplication NOTE: When multiplying matrices... the order matters!
pub const matrixTranslate = c.MatrixTranslate; // Get translation matrix
pub const matrixRotate = c.MatrixRotate; // Create rotation matrix from axis and angle NOTE: Angle should be provided in radians
pub const matrixRotateX = c.MatrixRotateX; // Get x-rotation matrix NOTE: Angle must be provided in radians
pub const matrixRotateY = c.MatrixRotateY; // Get y-rotation matrix NOTE: Angle must be provided in radians
pub const matrixRotateZ = c.MatrixRotateZ; // Get z-rotation matrix NOTE: Angle must be provided in radians
pub const matrixRotateXYZ = c.MatrixRotateXYZ; // Get xyz-rotation matrix NOTE: Angle must be provided in radians
pub const matrixRotateZYX = c.MatrixRotateZYX; // Get zyx-rotation matrix NOTE: Angle must be provided in radians
pub const matrixScale = c.MatrixScale; // Get scaling matrix
pub const matrixFrustum = c.MatrixFrustum; // Get perspective projection matrix
pub const matrixPerspective = c.MatrixPerspective; // Get perspective projection matrix NOTE: Fovy angle must be provided in radians
pub const matrixOrtho = c.MatrixOrtho; // Get orthographic projection matrix
pub const matrixLookAt = c.MatrixLookAt; // Get camera look-at matrix (view matrix)
pub const matrixToFloatV = c.MatrixToFloatV; // Get float array of matrix data

// Quaternion math
pub const quaternionAdd = c.QuaternionAdd; // Add two quaternions
pub const quaternionAddValue = c.QuaternionAddValue; // Add quaternion and float value
pub const quaternionSubtract = c.QuaternionSubtract; // Subtract two quaternions
pub const quaternionSubtractValue = c.QuaternionSubtractValue; // Subtract quaternion and float value
pub const quaternionIdentity = c.QuaternionIdentity; // Get identity quaternion
pub const quaternionLength = c.QuaternionLength; // Computes the length of a quaternion
pub const quaternionNormalize = c.QuaternionNormalize; // Normalize provided quaternion
pub const quaternionInvert = c.QuaternionInvert; // Invert provided quaternion
pub const quaternionMultiply = c.QuaternionMultiply; // Calculate two quaternion multiplication
pub const quaternionScale = c.QuaternionScale; // Scale quaternion by float value
pub const quaternionDivide = c.QuaternionDivide; // Divide two quaternions
pub const quaternionLerp = c.QuaternionLerp; // Calculate linear interpolation between two quaternions
pub const quaternionNlerp = c.QuaternionNlerp; // Calculate slerp-optimized interpolation between two quaternions
pub const quaternionSlerp = c.QuaternionSlerp; // Calculates spherical linear interpolation between two quaternions
pub const quaternionFromVector3ToVector3 = c.QuaternionFromVector3ToVector3; // Calculate quaternion based on the rotation from one vector to another
pub const quaternionFromMatrix = c.QuaternionFromMatrix; // Get a quaternion for a given rotation matrix
pub const quaternionToMatrix = c.QuaternionToMatrix; // Get a matrix for a given quaternion
pub const quaternionFromAxisAngle = c.QuaternionFromAxisAngle; // Get rotation quaternion for an angle and axis NOTE: Angle must be provided in radians
pub const quaternionToAxisAngle = c.QuaternionToAxisAngle; // Get the rotation angle and axis for a given quaternion
pub const quaternionFromEuler = c.QuaternionFromEuler; // Get the quaternion equivalent to Euler angles NOTE: Rotation order is ZYX
pub const quaternionToEuler = c.QuaternionToEuler; // Get the Euler angles equivalent to quaternion (roll, pitch, yaw) NOTE: Angles are returned in a Vector3 struct in radians
pub const quaternionTransform = c.QuaternionTransform; // Transform a quaternion given a transformation matrix
pub const quaternionEquals = c.QuaternionEquals; // Check whether two given quaternions are almost equal

// structs
pub const Vector2 = c.Vector2; // Vector2, 2 components
pub const Vector3 = c.Vector3; // Vector3, 3 components
pub const Vector4 = c.Vector4; // Vector4, 4 components
pub const Matrix = c.Matrix; // Matrix, 4x4 components, column major, OpenGL style, right handed
pub const Color = c.Color; // Color, 4 components, R8G8B8A8 (32bit)
pub const Rectangle = c.Rectangle; // Rectangle, 4 components

pub const Image = c.Image; // Image, pixel data stored in CPU memory (RAM)
pub const Texture = c.Texture; // Texture, tex data stored in GPU memory (VRAM)
pub const RenderTexture = c.RenderTexture; // RenderTexture, fbo for texture rendering
pub const NPatchInfo = c.NPatchInfo; // NPatchInfo, n-patch layout info
pub const GlyphInfo = c.GlyphInfo; // GlyphInfo, font characters glyphs info
pub const Font = c.Font; // Font, font texture and GlyphInfo array data

pub const Camera2D = c.Camera2D; // Camera2D, defines position/orientation in 2d space
pub const Camera3D = c.Camera3D; // Camera, defines position/orientation in 3d space

pub const Shader = c.Shader; // Shader
pub const MaterialMap = c.MaterialMap; // MaterialMap
pub const Material = c.Material; // Material, includes shader and maps
pub const Mesh = c.Mesh; // Mesh, vertex data and vao/vbo
pub const Model = c.Model; // Model, meshes, materials and animation data
pub const ModelAnimation = c.ModelAnimation; // ModelAnimation
pub const Transform = c.Transform; // Transform, vertex transformation data
pub const BoneInfo = c.BoneInfo; // Bone, skeletal animation bone
pub const Ray = c.Ray; // Ray, ray for raycasting
pub const RayCollision = c.RayCollision; // RayCollision, ray hit information
pub const BoundingBox = c.BoundingBox; // BoundingBox

pub const Wave = c.Wave; // Wave, audio wave data
pub const AudioStream = c.AudioStream; // AudioStream, custom audio stream
pub const Sound = c.Sound; // Sound
pub const Music = c.Music; // Music, audio stream, anything longer than ~10 seconds should be streamed

pub const VrDeviceInfo = c.VrDeviceInfo; // VrDeviceInfo, Head-Mounted-Display device parameters
pub const VrStereoConfig = c.VrStereoConfig; // VrStereoConfig, VR stereo rendering configuration for simulator

pub const FilePathList = c.FilePathList; // File path list

pub const AutomationEvent = c.AutomationEvent; // Automation event
pub const AutomationEventList = c.AutomationEventList; // Automation event list

pub const Texture2D = c.Texture2D;

// colors
// Custom raylib color palette for amazing visuals on WHITE background
pub const light_gray = c.LIGHTGRAY; // Light Gray
pub const gray = c.GRAY; // Gray
pub const dark_gray = c.DARKGRAY; // Dark Gray
pub const yellow = c.YELLOW; // Yellow
pub const gold = c.GOLD; // Gold
pub const orange = c.ORANGE; // Orange
pub const pink = c.PINK; // Pink
pub const red = c.RED; // Red
pub const maroon = c.MAROON; // Maroon
pub const green = c.GREEN; // Green
pub const lime = c.LIME; // Lime
pub const dark_green = c.DARKGREEN; // Dark Green
pub const skyblue = c.SKYBLUE; // Sky Blue
pub const blue = c.BLUE; // Blue
pub const dark_blue = c.DARKBLUE; // Dark Blue
pub const purple = c.PURPLE; // Purple
pub const violet = c.VIOLET; // Violet
pub const dark_purpl = c.DARKPURPLE; // Dark Purple
pub const beige = c.BEIGE; // Beige
pub const brown = c.BROWN; // Brown
pub const dark_brown = c.DARKBROWN; // Dark Brown

pub const white = c.WHITE; // White
pub const black = c.BLACK; // Black
pub const blank = c.BLANK; // Blank (Transparent)
pub const magenta = c.MAGENTA; // Magenta
pub const raywhite = c.RAYWHITE; // My own White (raylib logo)

pub fn getColor(hexValue: u32) Color {
    return Color{
        .r = @intCast((hexValue >> 24) & 0xFF),
        .g = @intCast((hexValue >> 16) & 0xFF),
        .b = @intCast((hexValue >> 8) & 0xFF),
        .a = @intCast(hexValue & 0xFF),
    };
}
