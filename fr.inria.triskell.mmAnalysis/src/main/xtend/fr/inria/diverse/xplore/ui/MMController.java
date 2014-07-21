package fr.inria.diverse.xplore.ui;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.ResourceBundle;
import java.util.stream.Collectors;

import javafx.collections.ObservableList;
import javafx.event.Event;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.scene.input.KeyEvent;
import javafx.stage.DirectoryChooser;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import fr.inria.diverse.mmAnalyser.MMProcessor;


public class MMController implements Initializable{
	private static final String NO_NSURI_LABEL = "<no NS URI>";
	
	private static final String CACHE_FILE = "xplore.cache";
	
	@FXML
	private TreeView<String> mmList;
	@FXML
	private TreeView<String> modelsList;
	@FXML 
	private Button mmfolder;
	@FXML
	private TextField searchField;
	@FXML 
	private Button modelsfolder;
	
	private DirectoryChooser dirChooser;
	
	private List<Path> mms = new ArrayList<>();
	private List<Path> models = new ArrayList<>();
	
	private TreeItem<String> defaultRoot = new TreeItem<>("Metamodels");
	private TreeItem<String> defaultRootModels = new TreeItem<>("Models");
	
	private File mmDir;
	private File modelsDir;
	
	
	@FXML
	protected void onSearchOnMM(KeyEvent evt) {
		mmList.setRoot(searchField.getText().length()==0?defaultRoot:getSearchedTree(searchField.getText()));
	}
	
	
//	private void writeCacheMetamodels() {
//		try (FileWriter fw = new FileWriter(new File(mmDir.getPath()+File.separatorChar+CACHE_FILE))) {
//			JSONWriter writer = new JSONWriter(fw);
//			
//		} catch (IOException e) {
//			e.printStackTrace();
//		}
//	}
	
	
	private TreeItem<String> getSearchedTree(String txt) {
		final TreeItem<String> newRoot = new TreeItem<>("Metamodels");
		final ObservableList<TreeItem<String>> newChildren = newRoot.getChildren();
		
		defaultRoot.getChildren().forEach(node -> {
			if(node.getValue().toLowerCase().contains(txt)) {
				newChildren.add(cloneTreeItem(node, node.getChildren()));
			}else {
				List<TreeItem<String>> c = node.getChildren().stream().filter(child -> child.getValue().toLowerCase().contains(txt)).collect(Collectors.toList());
				if(!c.isEmpty()) {
					newChildren.add(cloneTreeItem(node, c));
				}
			}
		});
		
		newChildren.sort((p1, p2) -> p1.getValue().compareToIgnoreCase(p2.getValue()));
		return newRoot;
	}
	
	private TreeItem<String> cloneTreeItem(TreeItem<String> src, List<TreeItem<String>> srcChildren) {
		final TreeItem<String> ti = new TreeItem<>(src.getValue());
		final List<TreeItem<String>> tiChildren = ti.getChildren();
		srcChildren.forEach(elt -> tiChildren.add(cloneTreeItem(elt, elt.getChildren())));
		return ti;
	}

	
	@FXML 
	protected void onClickModelsFolder(Event evt) {
		modelsDir = getFileChooser(false).showDialog(null);
		if(modelsDir==null || !modelsDir.canRead()) return;
		
		File cache = new File(modelsDir.getPath()+File.separatorChar+CACHE_FILE);
		
		if(cache.canRead()) {
			
		}else {
			models.clear();
			readModels(models, modelsDir.toPath(), Optional.empty());
			updateList(modelsList, models, modelsDir, false);
		}
	}
	
	
	private static void updateList(TreeView<String> tv, List<Path> models, File dir, boolean metamodel) {
		try{
			String dirStr = dir.getPath();
			DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = factory.newDocumentBuilder();
	
			ObservableList<TreeItem<String>> root = tv.getRoot().getChildren(); 
			root.clear();
			models.forEach(mm -> {
				try {
					Document document = builder.parse(mm.toFile());
					NodeList nl = document.getChildNodes();
					if(nl.getLength()>0 && nl.item(0).getAttributes()!=null) {
						Node nsURINode = null;
						
						if(metamodel) {
							nsURINode = nl.item(0).getAttributes().getNamedItem("nsURI");
						}else {
							String[] names = nl.item(0).getNodeName().split(":");
							switch(names.length) {
							case 1: nsURINode = nl.item(0).getAttributes().getNamedItem("xmlns"); break;
							case 2: nsURINode = nl.item(0).getAttributes().getNamedItem("xmlns:"+names[0]); break;
							}
						}
						
						String txt = nsURINode==null?NO_NSURI_LABEL:nsURINode.getNodeValue();
						TreeItem<String> ti = root.parallelStream().filter(elt -> elt.getValue().equals(txt)).findFirst().orElse(null);
	
						if(ti==null) {
							ti = new TreeItem<>(txt);
							root.add(ti);
						}
						ti.getChildren().add(new TreeItem<>(mm.toString().replace(dirStr, "")));
					}
				}catch(Exception e){}
			});
			root.sort((p1, p2) -> p1.getValue().compareToIgnoreCase(p2.getValue()));
			tv.getRoot().setExpanded(true);
		}catch(Exception ex){
		}
	}
	
	
	@FXML 
	protected void onClickMMFolder(Event evt) {
		mmDir = getFileChooser(true).showDialog(null);
		if(mmDir==null || !mmDir.canRead()) return;
		
		mms.clear();
		readModels(mms, mmDir.toPath(), Optional.of(MMProcessor.ecoreExt));
		updateList(mmList, mms, mmDir, true);
	}


	private static void readModels(List<Path> models, Path dir, Optional<String> extension) {
		try(DirectoryStream<Path> ds = Files.newDirectoryStream(dir)){
			ds.forEach(p -> {
				if(Files.isDirectory(p)) readModels(models, p, extension);
				else if(!extension.isPresent() || p.toString().endsWith(extension.get())) models.add(p);
			});
		}catch(IOException ex) {ex.printStackTrace();}
	}
	

	private DirectoryChooser getFileChooser(boolean metamodel) {
		if(dirChooser==null){
			dirChooser = new DirectoryChooser();
			dirChooser.setTitle(metamodel?"Metamodels Folder Selection":"Models Folder Selection");
		}
		
		return dirChooser;
	}
	

	@Override
	public void initialize(URL location, ResourceBundle resources) {
		mmList.setRoot(defaultRoot);
		mmList.setShowRoot(false);
		modelsList.setRoot(defaultRootModels);
		modelsList.setShowRoot(false);
	}
}
