package fr.inria.triskell.kompren.oclSlicer

import java.util.HashSet
import java.util.Set
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.ENamedElement

class OCLSlicer {
	protected val Set<EOperation> ops = new HashSet();
	protected val Set<EClass> classes = new HashSet();
	protected val Set<EStructuralFeature> features = new HashSet();
	protected val Set<EEnumLiteral> enumLiterals = new HashSet();
	protected val Set<EParameter> params = new HashSet();
	protected val Set<EObject> objects = new HashSet();
	protected val Set<EClassifier> classifiers = new HashSet();
	protected val Set<ENamedElement> elts = new HashSet();
}
