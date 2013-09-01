package fr.inria.triskell.kompren.oclSlicer;

import java.io.IOException;
import java.util.Collections;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EOperation;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.ocl.ParserException;
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory;
import org.eclipse.ocl.ecore.OCL;
import org.eclipse.ocl.helper.OCLHelper;

import LRBAC.LRBACPackage;

public class Test {
	public static void main(String[] args) {
		try {
		    // create an OCL instance for Ecore
		    OCL ocl = OCL.newInstance(EcoreEnvironmentFactory.INSTANCE);
		    int i = 0;
		    ResourceSet resSet = new ResourceSetImpl();
		    resSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xmi", new XMIResourceFactoryImpl());
		    Resource res = resSet.createResource(URI.createURI("out.xmi"));
		    
		    // create an OCL helper object
		    OCLHelper<EClassifier, EOperation, EStructuralFeature, org.eclipse.ocl.ecore.Constraint> helper = ocl.createOCLHelper();
		    
		    helper.setOperationContext(LRBACPackage.Literals.USER, LRBACPackage.Literals.USER.getEOperation(3));
		    res.getContents().add(i++, helper.createPrecondition("self.AssignedRoles->excludes(r) and r.AssignLoc->includes(self.UserLoc)"));
		    res.getContents().add(i++, helper.createPostcondition("self.AssignedRoles = self.AssignedRoles@pre->including(r)"));

		    helper.setOperationContext(LRBACPackage.Literals.USER, LRBACPackage.Literals.USER.getEOperation(4));
		    res.getContents().add(i++, helper.createPrecondition("self.UserID <> id"));
		    res.getContents().add(i++, helper.createPostcondition("self.UserID = id"));
		    
		    helper.setOperationContext(LRBACPackage.Literals.USER, LRBACPackage.Literals.USER.getEOperation(2));
		    res.getContents().add(i++, helper.createPrecondition("self.UserLoc->excludes(l) and self.AssignedRoles->isEmpty()"));
		    res.getContents().add(i++, helper.createPostcondition("self.UserLoc->includes(l)"));
		    
		    helper.setOperationContext(LRBACPackage.Literals.USER, LRBACPackage.Literals.USER.getEOperation(1));
		    res.getContents().add(i++, helper.createPrecondition("age > 0"));
		    res.getContents().add(i++, helper.createPostcondition("self.Age = age"));
		    
		    helper.setOperationContext(LRBACPackage.Literals.USER, LRBACPackage.Literals.USER.getEOperation(0));
		    res.getContents().add(i++, helper.createPrecondition("self.UserName <> name"));
		    res.getContents().add(i++, helper.createPostcondition("self.UserName = name"));
		    
		    helper.setOperationContext(LRBACPackage.Literals.SESSION, LRBACPackage.Literals.SESSION.getEOperation(0));
		    res.getContents().add(i++, helper.createPrecondition("self.MaxRoles <> NoOfRoles"));
		    res.getContents().add(i++, helper.createPostcondition("self.MaxRoles = NoOfRoles"));
		    
		    res.save(Collections.emptyMap());
		    res.unload();
		} catch (ParserException e) {
		    e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
