1. SnappingSheetController.
  allows the developer to control the snapping sheet position:
    * Change position by relative factor( factor f between 1 and 0 where
      1 = Full size, 0 = Smallest size) or by absolute pixels.
    * Execute the change with\without animation(for developer choice).
    * Stop the snapping of the snapping sheet (Make it disappear).

  allows the developer to extract information from the sheet:
    * If it is currently trying to snap to a position.
    * Current position of the sheet(bottom to top, where top is the grabbing widget).
    * Current snapping position of the sheet on the widget it is on top.
    * If a state is attached to this controller.

2. 'snappingCurve' in which the developer can determine the animation curve(which is used to adjust
    the rate of change of an animation over time, allowing them to speed up and slow down, rather
    than moving at a constant rate.) to the snapping position.

3. * InkWell - gives the developer common used(On Material design) splash animation 'for free', while
     GestureDetector doesn't gives that as it more 'raw' widget.
   * GestureDetector - Does not have any limitation on it's ancestor widgets, while InkWell must have
     Material widget as an ancestor, because it's Material design specific.

"# android-project-flutter-assignment" 
