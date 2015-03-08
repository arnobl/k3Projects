package fr.inria.diverse.xplore.ui;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.ResourceBundle;
import java.util.stream.Collectors;

import javafx.collections.ObservableList;
import javafx.fxml.FXML;
import javafx.fxml.Initializable;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.control.TreeItem;
import javafx.scene.control.TreeView;
import javafx.stage.DirectoryChooser;

import javax.xml.parsers.DocumentBuilderFactory;

import org.apache.commons.io.FilenameUtils;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import fr.inria.diverse.ecore.EcoreRegistering;
import fr.inria.diverse.mmAnalyser.MMProcessor;


public class MMController implements Initializable{
	private static final String NO_NSURI_LABEL = "<no NS URI>";
	
	private static final String CACHE_FILE = "xplore.cache";
	
	@FXML private TreeView<String> mmList;
	@FXML private TreeView<String> modelsList;
	@FXML private Button mmfolder;
	@FXML private TextField searchField;
	@FXML private Button modelsfolder;
	
	private DirectoryChooser dirChooser;
	private List<Path> mms = new ArrayList<>();
	private List<Path> models = new ArrayList<>();
	private TreeItem<String> defaultRoot = new TreeItem<>("Metamodels");
	private TreeItem<String> defaultRootModels = new TreeItem<>("Models");
	private File mmDir;
	private File modelsDir;
	
	
	@Override
	public void initialize(URL location, ResourceBundle resources) {
		if(!EPackage.Registry.INSTANCE.containsKey(EcorePackage.eNS_URI))
			EPackage.Registry.INSTANCE.put(EcorePackage.eNS_URI, EcorePackage.eINSTANCE);
		Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put("ecore", new EcoreResourceFactoryImpl());
		
		mmList.setOnMouseClicked(evt -> {
			if(evt.getClickCount()==2 && mmList.getSelectionModel().getSelectedItem()!=null && mmList.getSelectionModel().getSelectedItem().isLeaf()) {
				String mm = mmList.getSelectionModel().getSelectedItem().getValue();
				ResourceSet rs = new ResourceSetImpl();
				Resource res = rs.getResource(URI.createURI(mmDir.getPath()+mm), true);
				res.getContents().forEach(obj -> {
					if(obj instanceof EPackage)
						try {
							EcoreRegistering.registerPackages((EPackage)obj);
							searchForModels(mmList.getSelectionModel().getSelectedItem().getParent().getValue());
						}catch(final Exception e) {
							e.printStackTrace();
						}
				});
			}
		});
		
		searchField.setOnKeyPressed(evt -> mmList.setRoot(searchField.getText().length()==0?defaultRoot:getSearchedTree(searchField.getText())));
		
		modelsfolder.setOnAction(evt -> {
			modelsDir = getFileChooser(false).showDialog(null);
			if(modelsDir==null || !modelsDir.canRead()) return;
			
			File cache = new File(modelsDir.getPath()+File.separatorChar+CACHE_FILE);
			
			if(cache.canRead()) {
				
			}else {
				models.clear();
				readModels(models, modelsDir.toPath(), Optional.empty());
				updateList(modelsList, models, modelsDir, false);
			}
		});
		
		mmfolder.setOnAction(evt -> {
			mmDir = getFileChooser(true).showDialog(null);
			if(mmDir==null || !mmDir.canRead()) return;
			
			mms.clear();
			readModels(mms, mmDir.toPath(), Optional.of(MMProcessor.ecoreExt));
			updateList(mmList, mms, mmDir, true);
		});
		
		mmList.setRoot(defaultRoot);
		mmList.setShowRoot(false);
		modelsList.setRoot(defaultRootModels);
		modelsList.setShowRoot(false);
	}
	
	
	private void searchForModels(final String uriMM) {
		final String pathPrefix = modelsDir.getPath();
		final Map<String, Object> factory = Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap();
System.out.println(uriMM);
		modelsList.getRoot().getChildren().parallelStream().filter(item -> item.getValue().equals(uriMM)).findFirst().ifPresent(item ->
			item.getChildren().parallelStream().map(TreeItem::getValue).forEach(modelItem -> {
				try {
					final String ext = FilenameUtils.getExtension(modelItem);
					if(!factory.containsKey(ext)) {
						Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put(ext, new XMIResourceFactoryImpl());
					}
					
					// Loading the model
					ResourceSet rs = new ResourceSetImpl();
					Resource res = rs.getResource(URI.createURI(pathPrefix+modelItem), true);
					EcoreUtil.resolveAll(res);
					res.getContents().forEach(obj -> {
						System.out.println("OK: " + obj);
					});
					
					// Flushing resources
					Iterator<Resource> it =  rs.getResources().iterator();
					while(it.hasNext()) {
						it.next().unload();
						it.remove();
					}
				}catch(Exception ex) { 
					System.out.println(modelItem);
					ex.printStackTrace();
					}
		}));
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

	
	private static void updateList(TreeView<String> tv, List<Path> models, File dir, boolean metamodel) {
		try{
			String dirStr = dir.getPath();
	
			ObservableList<TreeItem<String>> root = tv.getRoot().getChildren(); 
			root.clear();
			List<Path> toRemove = new ArrayList<>();
			models.forEach(mm -> {
				try {
					NodeList nl = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(mm.toFile()).getChildNodes();
					
					if(nl.getLength()>0) {
						final Node firstRoot = nl.item(0);
						Node rootNode =  firstRoot;
						Node nsURINode = null;
						
						if(metamodel) {
							if(rootNode.getAttributes()!=null)
								nsURINode = rootNode.getAttributes().getNamedItem("nsURI");
						}else {
							if(rootNode.getNodeName().equalsIgnoreCase("xmi:xmi") || rootNode.getNodeName().equalsIgnoreCase("xmi")) {
								boolean ok = false;
								NodeList rootChildren = rootNode.getChildNodes();
								for(int i=0, size=rootChildren.getLength(); i<size && !ok; i++) {
									if(rootChildren.item(i).getNodeType()!=Node.TEXT_NODE) {
										ok = true;
										rootNode = rootChildren.item(i);
										rootChildren = rootNode.getChildNodes();
									}
								}
							}
							String[] names = rootNode.getNodeName().split(":");
							switch(names.length) {
								case 1: nsURINode = firstRoot.getAttributes().getNamedItem("xmlns"); break;
								case 2: nsURINode = firstRoot.getAttributes().getNamedItem("xmlns:"+names[0]); break;
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
				}catch(Exception e){
					toRemove.add(mm);
					System.out.println(mm);
					e.printStackTrace();
//					MMProcessor.passNotLoadable(mm, dir.getPath(), dir.getParent());
				}
			});
			models.removeAll(toRemove);
			root.sort((p1, p2) -> p1.getValue().compareToIgnoreCase(p2.getValue()));
			tv.getRoot().setExpanded(true);
		}catch(Exception ex){
			ex.printStackTrace();
		}
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
}
