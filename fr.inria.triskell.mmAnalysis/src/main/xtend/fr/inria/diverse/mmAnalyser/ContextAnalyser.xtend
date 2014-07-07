package fr.inria.diverse.mmAnalyser

import java.io.IOException
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EOperation
import java.nio.charset.Charset

class ContextAnalyser {
	val Map<String,String> mms = newHashMap()
	protected var String currentMM
	protected var double nbClasses = 0
	protected var double nbPackages = 0
	protected var double nbDataTypes = 0
	protected var double nbAttr = 0
	protected var double nbMetamodels = 0
	protected var double nbReferences = 0
	protected var double nbOperations = 0
	protected var double nbAnnotations = 0
	protected var double nbFactories = 0
	protected var double nbEnums = 0
	protected var double nbEnumsLiteral = 0
	protected var double nbGenerics = 0
	var count = 0
	
	protected val StringBuilder dataClass = new StringBuilder
	protected val StringBuilder dataOp = new StringBuilder
	protected val StringBuilder dataMM = new StringBuilder
	
	private val t = '\t'
	private val eol = '\n'
	private val tru = '1'
	private val fal = '0'


	public def void nextMetamodel(String name) {
		currentMM = name
		nbClasses = 0
		nbPackages = 0
		nbDataTypes = 0
		nbReferences = 0
		nbAttr = 0
		nbOperations = 0
		nbEnums = 0
		nbEnumsLiteral = 0
		nbFactories = 0
		nbGenerics = 0
		count++
	}
	
	def int getCount() { return count}
	
	
	public def void onEndMetamodelCheckDuplicate() {
		val String ident = nbClasses + " " + nbPackages + " " + nbDataTypes + " " + nbReferences + " " + nbAttr + " " + nbOperations + " " +
			nbEnums + " " + nbEnumsLiteral
		val otherName = mms.get(ident)
		if(otherName!=null && Utils::LevenshteinDistance(currentMM.toLowerCase, otherName.toLowerCase)<4) {
			throw new IllegalArgumentException
		}
		mms.put(ident, currentMM)
	}
	
	
	public def void writeDataClass(EClass clazz) {
		nbClasses++
		nbAttr += clazz.EAllAttributes.size
		nbReferences += clazz.EReferences.size
		nbGenerics += clazz.ETypeParameters.size
		
		dataClass.append(currentMM).append(t).append(clazz.name).append(t).append(
			if(clazz.abstract)tru else fal).append(t).append(clazz.EAllAttributes.size.toString).append(t).append(clazz.EAllOperations.size.toString).append(
			t).append(clazz.EAllReferences.size.toString).append(t).append(clazz.EAllSuperTypes.size.toString).append(t).
			append(clazz.ETypeParameters.size.toString).append(eol)
	}
	
	public def void writeDataOperation(EOperation op) {
		nbOperations++
		
		dataOp.append(currentMM).append(t).append(op.EContainingClass.name).append(t).append(op.name).append(t).append(
			op.lowerBound).append(t).append(op.upperBound).append(t).append(if(op.EType==null) '0' else '1').append(
			t).append(op.EParameters.size).append(eol)
	}
	
	public def void writeDataMM() {
		nbMetamodels = nbMetamodels + 1
		
		dataMM.append(currentMM).append(t).append(nbPackages.intValue).append(t).append(nbClasses.intValue).append(t).append(nbDataTypes.intValue).append(t).
		append(nbReferences.intValue).append(t).append(nbAttr.intValue).append(t).append(nbOperations.intValue).append(t).append(nbEnums.intValue).append(t).
		append(nbEnumsLiteral.intValue).append(t).append(nbFactories.intValue).append(t).append(eol)
	}
	
	
	public def void write() {
		var Path newFile = Paths.get("./dataClass.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		var buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tClass name\tAbstract\tNb Attrs\tnb Ops\tnb Refs\tnbSupers\tnbGenerics")
		buffer.newLine
		buffer.append(dataClass)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
		
		newFile = Paths.get("./dataOp.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tClass name\tOp name\tLower bound\tUpper bound\tHas return\tnb param")
		buffer.newLine
		buffer.append(dataOp)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
		
		newFile = Paths.get("./dataMM.txt")
		Files.deleteIfExists(newFile)
		newFile = Files.createFile(newFile)
		buffer = Files.newBufferedWriter(newFile, Charset.defaultCharset)
		buffer.append("Metamodel\tnb pkgs\tnb classes\tnb data types\tnb refs\tnb attrs\tnb ops\tnb enums\tnb enum literals\tnb factories")
		buffer.newLine
		buffer.append(dataMM)
		buffer.flush
		try { buffer.close }catch(IOException ex) { ex.printStackTrace }
	}
	
	
//	public override String toString() {
//		return "\nnb nbMetamodels: " + nbMetamodels +
//		"\nnb classes per MM: " + nbClasses/nbMetamodels + 
//		"\nnb data types per MM: " + nbDataTypes/nbMetamodels + 
//		"\nnb nb enums per MM (contained in data types): " + nbEnums/nbMetamodels + 
//		"\nnb nb enums literal per enum: " + nbEnumsLiteral/nbEnums + 
//		"\nnb packages per MM: " + nbPackages/nbMetamodels + 
//		"\nnb attributes per class: " + nbAttr/nbClasses +
//		"\nnb classes per pkg: " + nbClasses/nbPackages +
//		"\nnb references per class: " + nbReferences/nbClasses +
//		"\nnb annotations per metamodel: " + nbAnnotations/nbMetamodels +
//		"\nnb factory per metamodel: " + nbFactories/nbMetamodels
//	}
}