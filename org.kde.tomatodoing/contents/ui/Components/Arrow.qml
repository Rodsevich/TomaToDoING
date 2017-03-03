import QtQuick 2.7

Item{
    property color fillColor: "red"
    property color strokeColor: "black"
    property int strokeSize: 2

    onFillColorChanged: arr.requestPaint()
    onStrokeSizeChanged: arr.requestPaint()
    onStrokeColorChanged: arr.requestPaint()

    Canvas{
        id: arr

        width: parent.width
        height: parent.height
        onPaint: {
            var ctx = getContext('2d'),
                    headX = width / 3,
                    arrowBodyYtop = height / 3,
                    arrowBodyYbottom = height - arrowBodyYtop,
                    midY = height / 2;
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = strokeColor;
            ctx.lineWidth = strokeSize;
            ctx.fillStyle = fillColor;
            ctx.beginPath();
            ctx.moveTo(strokeSize, midY);
            ctx.lineTo(headX, strokeSize);
            ctx.lineTo(headX, arrowBodyYtop);
            ctx.lineTo(width - strokeSize, arrowBodyYtop);
            ctx.lineTo(width - strokeSize, arrowBodyYbottom);
            ctx.lineTo(headX, arrowBodyYbottom);
            ctx.lineTo(headX, height - strokeSize);
            ctx.lineTo(strokeSize,midY);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        }
    }

}
