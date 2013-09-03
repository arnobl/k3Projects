package fr.inria.triskell.kompren.oclSlicer

import java.util.HashSet
import java.util.Set
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EModelElement
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory
import org.eclipse.ocl.ecore.OCL
import org.eclipse.ocl.ecore.Constraint
import static extension fr.inria.triskell.kompren.oclSlicer.ConstraintAspect.*


class OCLSlicer {
	
	def static void main(String[] args) {
	    OCL.newInstance(EcoreEnvironmentFactory.INSTANCE)
	    // Register the XMI resource factory for the .website extension
	    val reg = Resource.Factory.Registry.INSTANCE
	    val m = reg.getExtensionToFactoryMap
	    m.put("xmi", new XMIResourceFactoryImpl())
		val slicer = new OCLSlicer
	
	    // Obtain a new resource set
	    val resSet = new ResourceSetImpl()
	
	    // Get the resource
	    val resource = resSet.getResource(URI.createURI("src/main/resources/models/PaperCst.xmi"), true)
	    resource.getContents.filter[res | res instanceof Constraint].forEach[
	    	cst | (cst as Constraint).visitToAddClasses(slicer)
	    ]
	}
	
	public val Set<EOperation> ops = new HashSet();
	public val Set<EClass> classes = new HashSet();
	public val Set<EStructuralFeature> features = new HashSet();
	public val Set<EEnumLiteral> enumLiterals = new HashSet();
	public val Set<EParameter> params = new HashSet();
	public val Set<EObject> objects = new HashSet();
	public val Set<EClassifier> classifiers = new HashSet();
	public val Set<EModelElement> elts = new HashSet();
}
