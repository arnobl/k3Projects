package fr.inria.diverse.xplore.ui;

import java.io.IOException;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Rectangle2D;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Screen;
import javafx.stage.Stage;

public class Xplorem extends Application {

	@Override
	public void start(Stage stage) throws IOException {
       Parent root = FXMLLoader.load(getClass().getResource("UI.fxml"));
       Scene scene = new Scene(root, 300, 275);
       stage.setTitle("Xplorem");
       stage.setScene(scene);
       Screen screen = Screen.getPrimary();
       Rectangle2D bounds = screen.getVisualBounds();

       
       stage.setX(bounds.getMinX());
       stage.setY(bounds.getMinY());
       stage.setWidth(bounds.getWidth());
       stage.setHeight(bounds.getHeight());
       stage.show();
	}

	public static void main(String[] args) {
		launch(args);
	}
}
